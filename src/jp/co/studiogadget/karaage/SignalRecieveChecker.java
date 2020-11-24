/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2020 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;
import java.time.DayOfWeek;
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
 * メタトレーダーが出力する当日のログ(yyyyMMdd.log)を読み込んで、<br>
 * シグナルの受信ができているかを確認します。<br>
 * 確認結果はメールで送信します。<br>
 * ログに特定の文字列が出力されているかで受信を確認します。<br>
 * <br>
 * 特定の文字列(文字大小区別なし)はMT4とMT5で共通で、全ての文字列が一致していること。<br>
 * これは1行あればOK<br>
 * previous successful authorization : ログイン<br>
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

        // プロパティファイル読込
        String logDir = PropertyUtil.getValue("signalRecieveChecker", "logDir");
        String signalName = PropertyUtil.getValue("signalRecieveChecker", "signalName");
        String mql5Account = PropertyUtil.getValue("signalRecieveChecker", "mql5Account");
        String mailTo = PropertyUtil.getValue("signalRecieveChecker", "mailTo");
        String platform = PropertyUtil.getValue("signalRecieveChecker", "platform");
        boolean checkEA = "TRUE".equals(PropertyUtil.getValue("signalRecieveChecker", "checkEA").toUpperCase());
        boolean summar = "TRUE".equals(PropertyUtil.getValue("signalRecieveChecker", "summar").toUpperCase());

        int startHour;
        if(summar) {
            startHour = 6;
        } else {
            startHour = 7;
        }

        // 当日の日付 (yyyyMMdd)
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyyMMdd");
        ZonedDateTime today = ZonedDateTime.now(JAPAN_ZONE_ID);

        // メタトレーダーのログディレクトリを開いておく
        // メタトレーダーのログディレクトリを開いた状態でメモ帳でログファイルを開くことにより
        // ログファイルを最新のものにするため
        Desktop.getDesktop().open(new File(logDir));

        //TODO 古いログファイルを削除する処理

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
                } else {
                    break;
                }
            } else {
                break;
            }
        }

        String date = today.format(df);

        DateTimeFormatter mdf = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
        String mailBody = today.format(mdf);

        try {
            // ログファイル
            String log = date + ".log";
            File logFile = new File(logDir + "/" + log);
            // Windows上でファイルの更新を認識させるためにメモ帳で開く
            Runtime rt = Runtime.getRuntime();
            try {
                rt.exec("notepad " + logFile.getPath());
                Thread.sleep(5 * 1000);
                rt.exec("taskkill /IM notepad.exe");
            } catch(Exception e) {
                logger.error("Open by Notepad Error.", e);
                MailUtil.send(mailTo, "ERROR " + signalName + " is Failed.", today.format(mdf) + "\r\nOpen by Notepad Error.\r\n" + e.getMessage());
            }

            // 条件クリアフラグ
            boolean termsAll = false; // 全条件クリア
            boolean terms1 = false; // 条件1
            boolean terms2 = false; // 条件2
            boolean terms3 = false; // 条件3
            boolean terms4 = false; // 条件4
            if(!checkEA) {
                terms3 = true;
            }
            boolean isLogin = false;

            String charset;
            if("MT4".equals(platform)) {
                charset = "UTF8";
            } else {
                charset = "UTF-16LE";
            }

            // ログファイル読込 (後ろから)
            ReversedLinesFileReader fr = null;
            try {
                fr = new ReversedLinesFileReader(logFile, IOUtils.DEFAULT_BUFFER_SIZE, charset);
                String line = null;
                while((line = fr.readLine()) != null) {

                    // 短い行はスキップ
                    if(line.length() < 50) {
                        continue;
                    }

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
                       && line.toLowerCase().contains("enabled")) {
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
                    if(terms1 && terms2 && terms3 && terms4 &&isLogin) {
                        termsAll = true;
                        break;
                    }
                }
                if(fr != null) {
                    fr.close();
                }

                // 結果に応じてメール作成
                String mailSubject;
                if(termsAll) {
                    mailSubject = signalName + " is Running.";
                } else {
                    mailSubject = "ERROR " + signalName + " is Failed.";
                    if(!terms1) {
                        mailBody += "\r\n Signal Disabled.";
                    }
                    if(!terms2) {
                        mailBody += "\r\n Connecting to Signal Server Failed.";
                    }
                    if(!terms3) {
                        mailBody += "\r\n EA Load Failed.";
                    }
                    if(!terms4) {
                        mailBody += "\r\n Signal Subscription Failed.";
                    }
                    if(!isLogin) {
                        mailBody += "\r\n Login Failed";
                    }
                }

                // メール送信
                MailUtil.send(mailTo, mailSubject, mailBody);

            } catch(IOException e) {
                logger.error("Logfile Read Error. [" + logFile.getPath() + "]", e);
                MailUtil.send(mailTo, "ERROR " + signalName + " Logfile Read Error.", mailBody + "\r\n" + e.getMessage());
                System.exit(1);
            }

            // 正常終了
            logger.info("****************** END ******************");
            System.exit(0);

        } catch(Exception e) {
            logger.error("Unexpected Error.", e);
            MailUtil.send(mailTo, "ERROR " + signalName + " Unexpected Error.", mailBody + "\r\n" + e.getMessage());
            System.exit(1);
        }

    }

}
