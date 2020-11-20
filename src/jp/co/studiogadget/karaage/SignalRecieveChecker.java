/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2015 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.io.File;
import java.io.IOException;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import org.apache.commons.io.IOUtils;
import org.apache.commons.io.input.ReversedLinesFileReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jp.co.studiogadget.common.util.MailUtil;
import jp.co.studiogadget.common.util.PropertyUtil;

/**
 * 当日のログ(yyyyMMdd.log)を読み込んで、シグナルの受信ができているかを確認します。<br>
 * 確認結果はメールで送信します。<br>
 * ログに特定の文字列が出力されているかで受信を確認します。<br>
 * <br>
 * 特定の文字列(文字大小区別なし)はMT4とMT5で共通で、全ての文字列が一致していること。<br>
 * これは1行あればOK<br>
 * Signal use 95% of deposit 0.00 USD 5.0 spreads enabled (同じ行) : 条件1 <br>
 * Signal connecting to signal server (同じ行) : 条件2<br>
 * <br>
 * 以下の条件は最後に出力されているログで一致する必要がある。<br>
 * expert SourceEA がある行に loaded successfully が表示されていること。 : 条件3<br>
 * Signal 'シグナル名' 'MQL5アカウント名' がある行に subscription found と enabled が表示されていること。 : 条件4<br>
 *
 * @author hidet
 *
 */
public class SignalRecieveChecker {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(SignalRecieveChecker.class);

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
        try {
            // プロパティファイル読込
            String logDir = PropertyUtil.getValue("signalRecieveChecker", "logDir");
            String signalName = PropertyUtil.getValue("signalRecieveChecker", "signalName");
            String mql5Account = PropertyUtil.getValue("signalRecieveChecker", "mql5Account");
            String mailTo = PropertyUtil.getValue("signalRecieveChecker", "mailTo");
            boolean checkEA = "TRUE".equals(PropertyUtil.getValue("signalRecieveChecker", "checkEA").toUpperCase());

            // 当日の日付 (yyyyMMdd)
            DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyyMMdd");
            ZonedDateTime today = ZonedDateTime.now(JAPAN_ZONE_ID);
            String date = today.format(df);

            // ログファイル
            String log = date + ".log";
            File logFile = new File(logDir + "/" + log);

            // 条件クリアフラグ
            boolean termsAll = false; // 全条件クリア
            boolean terms1 = false; // 条件1
            boolean terms2 = false; // 条件2
            boolean terms3 = false; // 条件3
            boolean terms4 = false; // 条件4
            if(!checkEA) {
                terms3 = true;
            }

            // ログファイル読込 (後ろから)
            ReversedLinesFileReader fr = null;
            try {
                fr = new ReversedLinesFileReader(logFile, IOUtils.DEFAULT_BUFFER_SIZE, "windows-31j");
                String line = null;
                while((line = fr.readLine()) != null) {

                    // 条件1
                    if(!terms1
                       & line.toLowerCase().contains("signal")
                       & line.toLowerCase().contains("use 95% of deposit")
                       & line.toLowerCase().contains("0.00 usd")
                       & line.toLowerCase().contains("5.0 spreads")
                       & line.toLowerCase().contains("enabled")) {
                        terms1 = true;
                    }

                    // 条件2
                    if(!terms2
                       & line.toLowerCase().contains("signal")
                       & line.toLowerCase().contains("connecting to signal server")) {
                        terms2 = true;
                    }

                    // 条件3
                    if(!terms3
                       & line.toLowerCase().contains("expert sourceea")) {
                        if(line.toLowerCase().contains("loaded successfully")) {
                            terms3 = true;
                        } else {
                            logger.warn("EA Load Faild.");
                            break;
                        }
                    }

                    // 条件4
                    if(!terms4
                       & line.toLowerCase().contains("signal")
                       & line.toLowerCase().contains(signalName.toLowerCase())
                       & line.toLowerCase().contains(mql5Account.toLowerCase())) {
                        if(line.toLowerCase().contains("subscription found")
                           & line.toLowerCase().contains("enabled")) {
                            terms4 = true;
                        } else {
                            logger.warn("Signal Subscription Faild.");
                            break;
                        }
                    }

                    // 条件をすべて満たしたら読込終了
                    if(terms1 & terms2 & terms3 & terms4) {
                        termsAll = true;
                        break;
                    }
                }
                fr.close();

                // 結果に応じてメール作成
                String mailSubject;
                DateTimeFormatter mdf = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
                String mailBody = today.format(mdf);
                if(termsAll) {
                    mailSubject = signalName + " is Started.";
                } else {
                    mailSubject = signalName + " is Faild.";
                    if(!terms1) {
                        mailBody += "\r\n Signal Disabled.";
                    }
                    if(!terms2) {
                        mailBody += "\r\n Connecting to Signal Server Failed.";
                    }
                    if(!terms3) {
                        mailBody += "\r\n EA Load Faild.";
                    }
                    if(!terms4) {
                        mailBody += "\r\n Signal Subscription Faild.";
                    }
                }

                // メール送信
                MailUtil.send(mailTo, mailSubject, mailBody);

            } catch(IOException e) {
                logger.error("Logfile Read Error. [" + logFile.getPath() + "]", e);
                throw new Exception(e);
            }

            // 正常終了
            logger.info("****************** END ******************");
            System.exit(0);

        } catch(Exception e) {
            logger.error("Unexpected Error.", e);
            System.exit(1);
        }

    }

}
