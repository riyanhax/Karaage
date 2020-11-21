/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2020 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.io.File;
import java.io.RandomAccessFile;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jp.co.studiogadget.common.util.MailUtil;
import jp.co.studiogadget.common.util.PropertyUtil;

/**
 * ForexCopierRecieverが出力する当日のログ(yyyyMMdd.log)を監視して、<br>
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

        // プロパティファイル読込
        String logDir = PropertyUtil.getValue("copyProviderChecker", "logDir");
        String mtLogDir = PropertyUtil.getValue("copyProviderChecker", "mtLogDir");
        String platform = PropertyUtil.getValue("signalRecieveChecker", "platform");
        String serverlName = PropertyUtil.getValue("copyProviderChecker", "serverlName");
        String mailTo = PropertyUtil.getValue("copyProviderChecker", "mailTo");
        int intervalMin = Integer.parseInt(PropertyUtil.getValue("copyProviderChecker", "intervalMin"));

        // 当日の日付 (yyyyMMdd)
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyyMMdd");
        DateTimeFormatter mdf = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");

        ZonedDateTime today = ZonedDateTime.now(JAPAN_ZONE_ID);
        RandomAccessFile raf = null;
        long pointer = 0L;

        try {
            // ファイル読込
            while(true) {
                today = ZonedDateTime.now(JAPAN_ZONE_ID);

                // 0時0分の場合はログファイルが変わるため、20分停止
                if(today.getHour() == 0
                   & today.getMinute() == 0) {
                    Thread.sleep(20 * 60 * 1000);
                }

                // ログファイル
                String date = today.format(df);
                String log = date + ".log";
                File logFile = new File(logDir + "/" + log);
                File mtLogFile = new File(mtLogDir + "/" + log);

                // メタトレーダーのログファイルのサイズチェック
                if(mtLogFile.length() >= 300 * 1024) {
                    logger.error("Logfile Size is Increasing.");
                    MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", today.format(mdf) + "\r\nLogfile Size is Increasing.");
                    System.exit(1);
                }

                // CopierRecieverのログファイルのエラーチェック
                raf = new RandomAccessFile(logFile, "r");
                raf.seek(pointer);
                boolean error = false;
                String line = null;
                while((line = raf.readLine()) != null) {

                    if(line.contains("[Error]")) {
                        error = true;
                    }
                }
                // エラーが発生した場合はメールを送信して終了
                if(error) {
                    logger.error("CopyReciever Error.");
                    MailUtil.send(mailTo, "ERROR " + serverlName + " is Failed.", today.format(mdf) + "\r\nCopyReciever Error.");
                    System.exit(1);
                }
                if(raf != null) {
                    // ポインターを更新
                    pointer = raf.length();
                    raf.close();
                }

                // TODO メタトレーダーのログファイルの動作チェック

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
