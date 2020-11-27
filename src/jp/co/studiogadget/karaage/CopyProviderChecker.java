/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2020 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

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
 * ForexCopierProvideが出力する当日のログ(yyyyMMdd.log)を監視して、<br>
 * エラーが発生していないことを確認します。<br>
 * エラーが発生した場合はメールを送信します。<br>
 * ログに特定の文字列が出力されているかでエラーを確認します。<br>
 * <br>
 * エラーを特定する文字列<br>
 * [Error]
 *
 * @author hidet
 *
 */
public class CopyProviderChecker {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(CopyProviderChecker.class);

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
        String logDir = PropertyUtil.getValue("copyProviderChecker", "logDir");
        String signalName = PropertyUtil.getValue("copyProviderChecker", "signalName");
        String mailTo = PropertyUtil.getValue("copyProviderChecker", "mailTo");
        int intervalMin = Integer.parseInt(PropertyUtil.getValue("copyProviderChecker", "intervalMin"));
        int logHistory = Integer.parseInt(PropertyUtil.getValue("copyProviderChecker", "logHistory"));
        boolean summar = "TRUE".equals(PropertyUtil.getValue("copyProviderChecker", "summar").toUpperCase());

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
        long pointer = 0L;
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
                if(today.getDayOfMonth() != startupDay) {
                    nextDay = true;
                    // ポインターをリセット
                    pointer = 0L;
                }

                // ログファイル
                String date = today.format(df);
                String log = date + ".log";
                File logFile = new File(logDir + "/" + log);
                // 日付が変わっている場合はログファイルが存在しない可能性がある
                if(!logFile.exists() && nextDay) {
                    // 一定時間停止
                    Thread.sleep(intervalMin * 60 * 1000);
                    continue;
                }
                logger.info("Length.[" + logFile.length()+ "]");

                raf = new RandomAccessFile(logFile, "r");
                raf.seek(pointer);

                boolean error = false;
                String line = null;
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
                    logger.error("ForexCopyProvider Error.");
                    MailUtil.send(mailTo, "ERROR " + signalName + " is Failed.", today.format(mdf) + "\r\nForexCopyProvider Error.");
                    System.exit(1);
                }

                if(raf != null) {
                    // ポインターを更新
                    pointer = raf.length();
                    raf.close();
                }

                // 一定時間停止
                Thread.sleep(intervalMin * 60 * 1000);
            }
        } catch(Exception e) {
            logger.error("Unexpected Error.", e);
            MailUtil.send(mailTo, "ERROR " + signalName + " Unexpected Error.", today.format(mdf) + "\r\n" + e.getMessage());
            System.exit(1);
        }

    }

}
