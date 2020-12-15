/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2020 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import javax.imageio.ImageIO;

import org.apache.commons.io.IOUtils;
import org.apache.commons.io.input.ReversedLinesFileReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jp.co.studiogadget.common.util.MailUtil;
import jp.co.studiogadget.common.util.PropertyUtil;

/**
 * 画面のキャプチャーを送信し、アプリが起動していることを確認できるようにします。(起動時に1回のみ)<br>
 * メタトレーダーが出力する操作履歴の当日のログ(yyyyMMdd.log)を読み込んで、<br>
 * シグナルの受信ができているかを確認します。(起動時に1回のみ)<br>
 * メタトレーダーが出力するエキスパートの当日のログ(yyyyMMdd.log)を監視して、<br>
 * エラーが発生していないことを確認します。(送信側と受信側の2つ)<br>
 * 確認結果はメールで送信します。<br>
 * ログに特定の文字列が出力されているかで受信を確認します。<br>
 * <br>
 * 操作履歴の確認文字列<br>
 * これは1行あればOK<br>
 * previous successful authorization : ログイン<br>
 * Signal use 95% of deposit 0.00 USD 5.0 spreads enabled (同じ行) : 条件1 <br>
 * Signal connecting to signal server (同じ行) : 条件2<br>
 * <br>
 * 以下の条件は最後に出力されているログで一致する必要がある。<br>
 * expert SourceEA がある行に loaded successfully が表示されていること。 : 条件3<br>
 * Signal 'シグナル名' 'MQL5アカウント名' がある行に subscription found と enabled が表示されていること。 : 条件4<br>
 * <br>
 * エキスパートの確認文字列<br>
 * * I am working ReceiverEA<br>
 * ※この文字列は10～15分ごとに出力される。<br>
 *
 * @author hidet
 *
 */
public class ForexCopierChecker {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(ForexCopierChecker.class);

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

        // プロパティファイル読込
        String logDir = PropertyUtil.getValue("forexCopierChecker", "logDir");
        String logDirSender = PropertyUtil.getValue("forexCopierChecker", "logDirSender");
        String logDirReciever = PropertyUtil.getValue("forexCopierChecker", "logDirReciever");
        String serverlName = PropertyUtil.getValue("forexCopierChecker", "serverlName");
        String signalName = PropertyUtil.getValue("forexCopierChecker", "signalName");
        String mql5Account = PropertyUtil.getValue("forexCopierChecker", "mql5Account");
        String mailTo = PropertyUtil.getValue("forexCopierChecker", "mailTo");
        int intervalMin = Integer.parseInt(PropertyUtil.getValue("forexCopierChecker", "intervalMin"));
        int logHistory = Integer.parseInt(PropertyUtil.getValue("forexCopierChecker", "logHistory"));
        boolean summar = "TRUE".equals(PropertyUtil.getValue("forexCopierChecker", "summar").toUpperCase());

        int startHour;
        if(summar) {
            startHour = 6;
        } else {
            startHour = 7;
        }

        // 当日の日付 (yyyyMMdd)
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyyMMdd");
        ZonedDateTime today = ZonedDateTime.now(JAPAN_ZONE_ID);
        RandomAccessFile rafSender = null;
        RandomAccessFile rafReciever = null;
        long pointerSender = 0L;
        long pointerReciever = 0L;
        int startupDay = today.getDayOfMonth();
        boolean nextDay = false;
        boolean firstCheck = true;

        // 古いログファイルを削除
        try {
            for(File file : new File(logDirSender).listFiles()) {
                if("metaeditor.log".equals(file.getName())) {
                    continue;
                }
                if(LocalDate.parse(file.getName().replace(".log", ""), df).atStartOfDay(today.getZone())
                        .compareTo(today.minusDays(logHistory)) < 0) {
                    file.delete();
                    logger.info("Old Logfile Deleted.[" + file.getPath() + "]");
                }
            }
        } catch(Exception e) {
            logger.warn("Old Logfile Delete Error.[" + logDirSender + "]", e);
        }
        try {
            for(File file : new File(logDirReciever).listFiles()) {
                if("metaeditor.log".equals(file.getName())) {
                    continue;
                }
                if(LocalDate.parse(file.getName().replace(".log", ""), df).atStartOfDay(today.getZone())
                        .compareTo(today.minusDays(logHistory)) < 0) {
                    file.delete();
                    logger.info("Old Logfile Deleted.[" + file.getPath() + "]");
                }
            }
        } catch(Exception e) {
            logger.warn("Old Logfile Delete Error.[" + logDirReciever + "]", e);
        }

        // 起動画面を取得
        Robot robot = new Robot();
        String pngPath = "C:/ForexCopierChecker/logs/"+ System.currentTimeMillis() +".png";
        ImageIO.write(robot.createScreenCapture(
                new Rectangle(0, 0, 1024, 768)), "png",new File(pngPath));

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
                pointerSender = 0L;
                pointerReciever = 0L;
            }
            // 日付が変わってすぐはログファイルにログが出力されていないので20分間停止
            if(today.getHour() == 0
               && today.getMinute() < 20) {
                Thread.sleep(20 * 60 * 1000);
                continue;
            }

            String date = today.format(df);
            DateTimeFormatter mdf = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
            String mailBody = today.format(mdf);

            try {
                // ログファイル
                String log = date + ".log";
                File logFile = new File(logDir + "/" + log);
                File logFileSender = new File(logDirSender + "/" + log);
                File logFileReciever = new File(logDirReciever + "/" + log);

                // ************* メタトレーダーのログを更新する 開始 ***********
                // シグナル送信のMT4にフォーカス
                robot.mouseMove(112, 755);
                robot.mousePress(InputEvent.BUTTON1_DOWN_MASK); // 左クリック
                robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
                Thread.sleep(1 * 1000);
                if(firstCheck) {
                    // メタトレーダーを操作して操作履歴ディレクトリを開く
                    robot.mouseMove(780, 700); // 操作履歴タブにマウスカーソルを移動
                    robot.mousePress(InputEvent.BUTTON1_DOWN_MASK); // 左クリック
                    robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
                    Thread.sleep(1 * 1000);
                    robot.mouseMove(780, 677); // ターミナルにマウスカーソルを移動
                    robot.mousePress(InputEvent.BUTTON3_DOWN_MASK); // 右クリック
                    robot.mouseRelease(InputEvent.BUTTON3_DOWN_MASK);
                    Thread.sleep(1 * 1000);
                    robot.keyPress(KeyEvent.VK_CONTROL); // Ctrl + O
                    robot.keyPress(KeyEvent.VK_O);
                    robot.keyRelease(KeyEvent.VK_CONTROL);
                    robot.keyRelease(KeyEvent.VK_O);
                    Thread.sleep(2 * 1000); // 操作履歴ログディレクトリが開くのを待つ

                    // Windows上でファイルの更新を認識させるためにメモ帳で開く
                    Runtime rt = Runtime.getRuntime();
                    try {
                        rt.exec("notepad " + logFile.getPath());
                        Thread.sleep(2 * 1000);
                        rt.exec("taskkill /IM notepad.exe");
                    } catch(Exception e) {
                        logger.error("Open by Notepad Error.", e);
                        MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", today.format(mdf) + "\r\nOpen by Notepad Error.\r\n" + e.getMessage());
                    }
                    Thread.sleep(2 * 1000); // メモ帳が閉じるのを待つ

                    // 操作履歴ログディレクトリを閉じる
                    robot.keyPress(KeyEvent.VK_ALT); // Alt + TAB (操作履歴ログディレクトリにフォーカスする)
                    robot.keyPress(KeyEvent.VK_TAB);
                    robot.keyRelease(KeyEvent.VK_ALT);
                    robot.keyRelease(KeyEvent.VK_TAB);
                    Thread.sleep(1 * 1000);
                    robot.keyPress(KeyEvent.VK_ALT); // Alt + F4 (操作履歴ログディレクトリを閉じる)
                    robot.keyPress(KeyEvent.VK_F4);
                    robot.keyRelease(KeyEvent.VK_ALT);
                    robot.keyRelease(KeyEvent.VK_F4);
                    Thread.sleep(1 * 1000);
                }

                // メタトレーダーを操作してエキスパートディレクトリを開く
                robot.mouseMove(713, 700); // エキスパートタブにマウスカーソルを移動
                robot.mousePress(InputEvent.BUTTON1_DOWN_MASK); // 左クリック
                robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
                Thread.sleep(1 * 1000);
                robot.mouseMove(713, 677); // ターミナルにマウスカーソルを移動
                robot.mousePress(InputEvent.BUTTON3_DOWN_MASK); // 右クリック
                robot.mouseRelease(InputEvent.BUTTON3_DOWN_MASK);
                Thread.sleep(1 * 1000);
                robot.keyPress(KeyEvent.VK_CONTROL); // Ctrl + O
                robot.keyPress(KeyEvent.VK_O);
                robot.keyRelease(KeyEvent.VK_CONTROL);
                robot.keyRelease(KeyEvent.VK_O);
                Thread.sleep(2 * 1000); // エキスパートログディレクトリが開くのを待つ

                // Windows上でファイルの更新を認識させるためにメモ帳で開く
                Runtime rt = Runtime.getRuntime();
                try {
                    rt.exec("notepad " + logFileSender.getPath());
                    Thread.sleep(2 * 1000);
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
                robot.keyPress(KeyEvent.VK_ALT); // Alt + F4 (操作履歴ログディレクトリを閉じる)
                robot.keyPress(KeyEvent.VK_F4);
                robot.keyRelease(KeyEvent.VK_ALT);
                robot.keyRelease(KeyEvent.VK_F4);
                Thread.sleep(1 * 1000);

                // シグナル受信のMT4にフォーカス
                robot.mouseMove(155, 755);
                robot.mousePress(InputEvent.BUTTON1_DOWN_MASK); // 左クリック
                robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
                Thread.sleep(1 * 1000);
                // メタトレーダーを操作してエキスパートディレクトリを開く
                robot.mouseMove(713, 700); // エキスパートタブにマウスカーソルを移動
                robot.mousePress(InputEvent.BUTTON1_DOWN_MASK); // 左クリック
                robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK);
                Thread.sleep(1 * 1000);
                robot.mouseMove(713, 677); // ターミナルにマウスカーソルを移動
                robot.mousePress(InputEvent.BUTTON3_DOWN_MASK); // 右クリック
                robot.mouseRelease(InputEvent.BUTTON3_DOWN_MASK);
                Thread.sleep(1 * 1000);
                robot.keyPress(KeyEvent.VK_CONTROL); // Ctrl + O
                robot.keyPress(KeyEvent.VK_O);
                robot.keyRelease(KeyEvent.VK_CONTROL);
                robot.keyRelease(KeyEvent.VK_O);
                Thread.sleep(2 * 1000); // エキスパートログディレクトリが開くのを待つ

                // Windows上でファイルの更新を認識させるためにメモ帳で開く
                try {
                    rt.exec("notepad " + logFileReciever.getPath());
                    Thread.sleep(2 * 1000);
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
                robot.keyPress(KeyEvent.VK_ALT); // Alt + F4 (操作履歴ログディレクトリを閉じる)
                robot.keyPress(KeyEvent.VK_F4);
                robot.keyRelease(KeyEvent.VK_ALT);
                robot.keyRelease(KeyEvent.VK_F4);
                Thread.sleep(1 * 1000);
                // ************* メタトレーダーのログを更新する 終了 ***********

                // 送信側操作履歴
                if(firstCheck) {
                    // 条件クリアフラグ
                    boolean termsAll = false; // 全条件クリア
                    boolean terms1 = false; // 条件1
                    boolean terms2 = false; // 条件2
                    boolean terms3 = false; // 条件3
                    boolean terms4 = false; // 条件4
                    boolean isLogin = false;

                    // ログファイル読込 (後ろから)
                    ReversedLinesFileReader fr = null;
                    try {
                        fr = new ReversedLinesFileReader(logFile, IOUtils.DEFAULT_BUFFER_SIZE, "UTF8");
                        String line = null;
                        while((line = fr.readLine()) != null) {

                            // ログインチェック
                            if(!isLogin
                               && line.toLowerCase().contains("previous successful authorization")) {
                                isLogin = true;
                            }

                            // 条件1
                            if(!terms1
                               && line.toLowerCase().contains("signal")
                               && line.toLowerCase().contains("use 95% of deposit")
                               && line.toLowerCase().contains("0.00 usd")
                               && line.toLowerCase().contains("5.0 spreads")
                               && line.toLowerCase().contains("disabled")) {
                                terms1 = true;
                            }

                            // 条件2
                            if(!terms2
                               && line.toLowerCase().contains("signal")
                               && line.toLowerCase().contains("connecting to signal server")) {
                                terms2 = true;
                            }

                            // 条件3
                            if(!terms3
                               && line.toLowerCase().contains("expert sourceea")) {
                                if(line.toLowerCase().contains("loaded successfully")) {
                                    terms3 = true;
                                } else {
                                    logger.warn("EA Load Failed.");
                                    break;
                                }
                            }

                            // 条件4
                            if(!terms4
                               && line.toLowerCase().contains("signal")
                               && line.toLowerCase().contains(signalName.toLowerCase())
                               && line.toLowerCase().contains(mql5Account.toLowerCase())) {
                                if(line.toLowerCase().contains("subscription found")
                                   && line.toLowerCase().contains("enabled")) {
                                    terms4 = true;
                                } else {
                                    logger.warn("Signal Subscription Failed.");
                                    break;
                                }
                            }

                            // 条件をすべて満たしたら読込終了
                            if(terms1 && terms2 && terms3 && terms4 && isLogin) {
                                termsAll = true;
                                break;
                            }

                            // 読込終了 (MT4 build、started)
                            if(line.toLowerCase().contains("mt4 build")
                               && line.toLowerCase().contains("started")) {
                                break;
                            }
                        }
                        if(fr != null) {
                            fr.close();
                        }

                        // 結果に応じてメール作成
                        String mailSubject;
                        if(termsAll) {
                            logger.info(serverlName + " is Running.");
                            mailSubject = serverlName + " is Running.";
                        } else {
                            logger.error(serverlName + " is Failed.");
                            mailSubject = "ERROR " + serverlName + " is Failed.";
                            if(!terms1) {
                                logger.error("Signal Disabled.");
                                mailBody += "\r\n Signal Disabled.";
                            }
                            if(!terms2) {
                                logger.error("Connecting to Signal Server Failed.");
                                mailBody += "\r\n Connecting to Signal Server Failed.";
                            }
                            if(!terms3) {
                                logger.error("EA Load Failed.");
                                mailBody += "\r\n EA Load Failed.";
                            }
                            if(!terms4) {
                                logger.error("Signal Subscription Failed.");
                                mailBody += "\r\n Signal Subscription Failed.";
                            }
                            if(!isLogin) {
                                logger.error("Login Failed");
                                mailBody += "\r\n Login Failed.";
                            }
                        }

                        // メール送信
                        MailUtil.send(mailTo, mailSubject, mailBody, pngPath);
                        if(!terms1 || !terms2 || !terms3 || !terms4 || !isLogin) {
                            System.exit(1);
                        }

                        if(firstCheck) {
                            firstCheck = false;
                        }

                    } catch(IOException e) {
                        logger.error("Logfile Read Error. [" + logFile.getPath() + "]", e);
                        MailUtil.send(mailTo, "ERROR " + serverlName + " Logfile Read Error.", mailBody + "\r\n" + e.getMessage());
                        System.exit(1);
                    }
                }

                // 送信側エキスパート
                rafSender = new RandomAccessFile(logFileSender, "r");
                rafSender.seek(pointerSender);
                boolean isWorkSender = false;
                String line = null;
                while((line = rafSender.readLine()) != null) {
                    if(line.toLowerCase().contains("i am working")
                       && line.toLowerCase().contains("sourceea")) {
                        isWorkSender = true;
                    }
                }
                // 動作していない場合はメールを送信して終了
                if(!isWorkSender) {
                    logger.error("SourceEA Error.");
                    MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", mailBody + "\r\nSourceEA Error.");
                }
                if(rafSender != null) {
                    // ポインターを更新
                    pointerSender = rafSender.length();
                    rafSender.close();
                }

                // 受信側エキスパート
                rafReciever = new RandomAccessFile(logFileReciever, "r");
                rafReciever.seek(pointerReciever);
                boolean isWorkReciever = false;
                line = null;
                while((line = rafReciever.readLine()) != null) {
                    if(line.toLowerCase().contains("i am working")
                       && line.toLowerCase().contains("receiverea")) {
                        isWorkReciever = true;
                    }
                    if(line.toLowerCase().contains("i am initialized")
                            && line.toLowerCase().contains("receiverea")) {
                        isWorkReciever = true;
                    }
                }
                // 動作していない場合はメールを送信して終了
                if(!isWorkReciever) {
                    logger.error("RecieverEA Error.");
                    MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", mailBody + "\r\nRecieverEA Error.");
                }
                if(rafReciever != null) {
                    // ポインターを更新
                    pointerReciever = rafReciever.length();
                    rafReciever.close();
                }

                if(!isWorkSender || !isWorkReciever) {
                    System.exit(1);
                }

                // 一定時間停止
                Thread.sleep(intervalMin * 60 * 1000);

            } catch(Exception e) {
                logger.error("Unexpected Error.", e);
                MailUtil.send(mailTo, "ERROR " + serverlName + " Unexpected Error.", mailBody + "\r\n" + e.getMessage());
                System.exit(1);
            }
        }

    }

}
