/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2020 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.awt.Robot;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.RandomAccessFile;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jp.co.studiogadget.common.util.MailUtil;
import jp.co.studiogadget.common.util.PropertyUtil;

/**
 * ForexCopierRecieverが出力するエキスパートの当日のログ(yyyyMMdd.log)を監視して、<br>
 * エラーが発生していないことを確認します。<br>
 * エラーが発生した場合はメールを送信します。<br>
 * ログに特定の文字列が出力されているかでエラーを確認します。<br>
 * エラーを特定する文字列<br>
 * [Error]<br>
 * <br>
 * <br>
 * メタトレーダーが出力する当日のログ(yyyyMMdd.log)を監視して、<br>
 * ReciverEAが正しく動作しているかを確認します。<br>
 * 正しく動作していない場合はメールを送信します。<br>
 * 動作を特定する文字列<br>
 * I am working ReceiverEA<br>
 * ※この文字列は15分ごとに出力される。<br>
 * <br>
 * <br>
 * メタトレーダーが出力する当日のログ(yyyyMMdd.log)を監視して、<br>
 * 300kB以上になっていないことを確認します。<br>
 * 300kB以上になっている場合はメールを送信します。
 *
 * @author hidet
 *
 */
public class CopyRecieverChecker {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(CopyRecieverChecker.class);

    /** 日本のゾーンID */
    public static final ZoneId JAPAN_ZONE_ID = ZoneId.of("Asia/Tokyo");

    /**
     * メインメソッド。
     *
     * @param args 引数なし
     * @throws Exception 例外
     */
    public static void main(String[] args) throws Exception {
        logger.info("***************** START *****************");

//        // 画面の解像度
//        int screenWidth =  Toolkit.getDefaultToolkit().getScreenSize().width;
//        int screenHeight =  Toolkit.getDefaultToolkit().getScreenSize().height;
//        logger.info(screenWidth + " x " + screenHeight);

        // プロパティファイル読込
        String logDir = PropertyUtil.getValue("copyRecieverChecker", "logDir");
        String mtLogDir = PropertyUtil.getValue("copyRecieverChecker", "mtLogDir");
        int logSizeLimitK = Integer.parseInt(PropertyUtil.getValue("copyRecieverChecker", "logSizeLimitK"));
        String serverlName = PropertyUtil.getValue("copyRecieverChecker", "serverlName");
        String mailTo = PropertyUtil.getValue("copyRecieverChecker", "mailTo");
        int intervalMin = Integer.parseInt(PropertyUtil.getValue("copyRecieverChecker", "intervalMin"));
        int logHistory = Integer.parseInt(PropertyUtil.getValue("copyRecieverChecker", "logHistory"));
        boolean summar = "TRUE".equals(PropertyUtil.getValue("copyRecieverChecker", "summar").toUpperCase());

        int startHour;
        if(summar) {
            startHour = 6;
        } else {
            startHour = 7;
        }

        // 当日の日付 (yyyyMMdd)
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyyMMdd");
        DateTimeFormatter mdf = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");

        ZonedDateTime today = ZonedDateTime.now(JAPAN_ZONE_ID);
        RandomAccessFile raf = null;
        RandomAccessFile mtRaf = null;
        long pointer = 0L;
        long mtPointer = 0L;
        int startupDay = today.getDayOfMonth();
        boolean nextDay = false;

        // 古いログファイルを削除
        try {
            for(File file : new File(logDir).listFiles()) {
                if(LocalDate.parse(file.getName().replace(".log", ""), df).atStartOfDay(today.getZone())
                        .compareTo(today.minusDays(logHistory)) < 0) {
                    file.delete();
                    logger.info("Old Logfile Deleted.[" + file.getPath() + "]");
                }
            }
        } catch(Exception e) {
            logger.warn("Old Logfile Delete Error.[" + logDir + "]", e);
        }

        try {
            for(File file : new File(mtLogDir).listFiles()) {
                if(LocalDate.parse(file.getName().replace(".log", ""), df).atStartOfDay(today.getZone())
                        .compareTo(today.minusDays(logHistory)) < 0) {
                    file.delete();
                    logger.info("Old Logfile Deleted.[" + file.getPath() + "]");
                }
            }
        } catch(Exception e) {
            logger.warn("Old Logfile Delete Error.[" + mtLogDir + "]", e);
        }


        try {
            // ファイル読込
            while(true) {
                logger.info("Execute.");
                today = ZonedDateTime.now(JAPAN_ZONE_ID);

                // 取引開始まで停止
                if(DayOfWeek.MONDAY.equals(today.getDayOfWeek())) {
                    if(today.getHour() < startHour) {
                        Thread.sleep(5 * 60 * 1000);
                        continue;
                    } else if(today.getHour() == startHour && today.getMinute() < 5) {
                        Thread.sleep(1 * 60 * 1000);
                        continue;
                    }
                }

                // 起動時と日付が変わっていたら、日付変更フラグを立てる
                if(!nextDay && today.getDayOfMonth() != startupDay) {
                    nextDay = true;
                    // ポインターをリセット
                    pointer = 0L;
                    mtPointer = 0L;
                }
                // 日付が変わってすぐはログファイルにログが出力されていないので20分間停止
                if(today.getHour() == 0
                   && today.getMinute() < 20) {
                    Thread.sleep(20 * 60 * 1000);
                    continue;
                }

                // ログファイル
                String date = today.format(df);
                String log = date + ".log";
                File logFile = new File(logDir + "/" + log);
                File mtLogFile = new File(mtLogDir + "/" + log);
                String line = null;

                // ************* メタトレーダーのログを更新する 開始 ***********
                // メタトレーダーを操作してエキスパートログディレクトリを開く
                Robot robot = new Robot();
//                ImageIO.write(robot.createScreenCapture(new Rectangle(0, 0, 1920, 1080)), "png", new File("C:/CopyRecieverChecker/logs/"+ System.currentTimeMillis() +"_1.png"));
//                robot.mouseMove(680, 1010); // エキスパートタブにマウスカーソルを移動 (1920x1080)
                robot.mouseMove(680, 698); // エキスパートタブにマウスカーソルを移動 (1024x768)
                robot.mousePress(InputEvent.BUTTON1_DOWN_MASK); // 左クリック
                robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
                Thread.sleep(1 * 1000);
//                ImageIO.write(robot.createScreenCapture(new Rectangle(0, 0, 1920, 1080)), "png", new File("C:/CopyRecieverChecker/logs/"+ System.currentTimeMillis() +"_2.png"));
//                robot.mouseMove(680, 980); // ターミナルにマウスカーソルを移動 (1920x1080)
                robot.mouseMove(680, 677); // ターミナルにマウスカーソルを移動 (1024x768)
                robot.mousePress(InputEvent.BUTTON3_DOWN_MASK); // 右クリック
                robot.mouseRelease(InputEvent.BUTTON3_DOWN_MASK);
                Thread.sleep(1 * 1000);
//                ImageIO.write(robot.createScreenCapture(new Rectangle(0, 0, 1920, 1080)), "png", new File("C:/CopyRecieverChecker/logs/"+ System.currentTimeMillis() +"_3.png"));
                robot.keyPress(KeyEvent.VK_CONTROL); // Ctrl + O
                robot.keyPress(KeyEvent.VK_O);
                robot.keyRelease(KeyEvent.VK_CONTROL);
                robot.keyRelease(KeyEvent.VK_O);
                Thread.sleep(2 * 1000); // エキスパートログディレクトリが開くのを待つ
//                ImageIO.write(robot.createScreenCapture(new Rectangle(0, 0, 1920, 1080)), "png", new File("C:/CopyRecieverChecker/logs/"+ System.currentTimeMillis() +"_4.png"));

                // Windows上でファイルの更新を認識させるためにメモ帳で開く
                Runtime rt = Runtime.getRuntime();
                try {
                    rt.exec("notepad " + mtLogFile.getPath());
                    Thread.sleep(2 * 1000);
//                    ImageIO.write(robot.createScreenCapture(new Rectangle(0, 0, 1920, 1080)), "png", new File("C:/CopyRecieverChecker/logs/"+ System.currentTimeMillis() +"_5.png"));
                    rt.exec("taskkill /IM notepad.exe");
                } catch(Exception e) {
                    logger.error("Open by Notepad Error.", e);
                    MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", today.format(mdf) + "\r\nOpen by Notepad Error.\r\n" + e.getMessage());
                }
                Thread.sleep(2 * 1000); // メモ帳が閉じるのを待つ

                // エキスパートログディレクトリを閉じる
                robot.keyPress(KeyEvent.VK_ALT); // Alt + TAB (エキスパートログディレクトリにフォーカスする)
                robot.keyPress(KeyEvent.VK_TAB);
                robot.keyRelease(KeyEvent.VK_ALT);
                robot.keyRelease(KeyEvent.VK_TAB);
                Thread.sleep(1 * 1000);
                robot.keyPress(KeyEvent.VK_ALT); // Alt + F4 (エキスパートログディレクトリを閉じる)
                robot.keyPress(KeyEvent.VK_F4);
                robot.keyRelease(KeyEvent.VK_ALT);
                robot.keyRelease(KeyEvent.VK_F4);
                Thread.sleep(1 * 1000);
             // ************* メタトレーダーのログを更新する 終了 ***********

                // メタトレーダーのログファイルのサイズチェック
                // 指定ファイルサイズ以上になった場合は、メールを送信して終了
                logger.info("MtLength.[" + mtLogFile.length() + "]");
                if(mtLogFile.length() >= logSizeLimitK * 1024) {
                    logger.error("Logfile Size is Increasing.");
                    MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", today.format(mdf) + "\r\nLogfile Size is Increasing.");
                    System.exit(1);
                }

                // ForexCopyRecieverのログファイルのエラーチェック
                if(logFile.exists()
                   || (!logFile.exists() && !nextDay)) {
                    logger.info("Length.[" + logFile.length() + "]");
                    raf = new RandomAccessFile(logFile, "r");
                    raf.seek(pointer);
                    boolean error = false;
                    while((line = raf.readLine()) != null) {
                        if(line.contains("[Error]")) {
                            error = true;
                        }

                        if(line.contains("Connection reconnected")) {
                            error = false;
                        }
                        if(line.contains("Connection established")) {
                            error = false;
                        }
                    }
                    // エラーが発生した場合はメールを送信して終了
                    if(error) {
                        logger.error("ForexCopyReciever Error.");
                        MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", today.format(mdf) + "\r\nForexCopyReciever Error.");
                        System.exit(1);
                    }
                    if(raf != null) {
                        // ポインターを更新
                        pointer = raf.length();
                        raf.close();
                    }
                } // (!logFile.exists() && nextDay )は通過

                // メタトレーダーのログファイルで動作チェック
                mtRaf = new RandomAccessFile(mtLogFile, "r");
                mtRaf.seek(mtPointer);
                boolean isWork = false;
                line = null;
                while((line = mtRaf.readLine()) != null) {
                    if(line.toLowerCase().contains("i am working")
                       && line.toLowerCase().contains("receiverea")) {
                        isWork = true;
                    }
                }
                // 動作していない場合はメールを送信して終了
                if(!isWork) {
                    logger.error("RecieverEA Error.");
                    MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", today.format(mdf) + "\r\nRecieverEA Error.");
                    System.exit(1);
                }
                if(mtRaf != null) {
                    // ポインターを更新
                    mtPointer = mtRaf.length();
                    mtRaf.close();
                }

                // 一定時間停止
                Thread.sleep(intervalMin * 60 * 1000);
            }
        } catch(Exception e) {
            logger.error("Unexpected Error.", e);
            MailUtil.send(mailTo, "ERROR " + serverlName + " Unexpected Error.", today.format(mdf) + "\r\n" + e.getMessage());
            System.exit(1);
        }

    }

}
