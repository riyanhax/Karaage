/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2015 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.ui4j.api.browser.BrowserFactory;
import com.ui4j.api.browser.Page;
import com.ui4j.api.browser.PageConfiguration;
import com.ui4j.api.dom.Document;
import com.ui4j.api.dom.Element;

import jp.co.studiogadget.common.util.MailUtil;
import jp.co.studiogadget.common.util.PropertyUtil;
import jp.co.studiogadget.karaage.param.EconomicIndicator;

/**
 * みんなの外為(http://fx.minkabu.jp/indicators/calendar)から経済指標発表時間を取得しCSV形式で出力します。
 *
 * @author hidet
 *
 */
public class StopTimeCreaterGMO {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(StopTimeCreaterGMO.class);

    /** ページURL */
    private static final String URL = "https://www.click-sec.com/corp/guide/fxneo/cal/";

    /** 日本のゾーンID */
    public static final ZoneId JAPAN_ZONE_ID = ZoneId.of("Asia/Tokyo");

    /** メール送信先 */
    private static String to;

    /** カウンター */
    private static int counter = 0;

    /** 引数 */
    private static String[] argsTmp;

    /**
     * メインメソッド。
     *
     * @param args 出力先ディレクトリ(無しの場合自動設定)
     * @throws Exception 例外
     */
    public static void main(String[] args) throws Exception {
        logger.info("***************** START *****************");
        argsTmp = args; // 引数保存
        try {
            String outputDir;
            String url = null;
            if(args.length == 0) {
                logger.debug("main()");
                outputDir = new File(new File(
                        StopTimeCreaterGMO.class.getClassLoader().getResource("karaage.properties").getPath()).getParent()).getParent() + "/data";
            } else if(args.length == 2) {
                logger.debug("main(" + args[0] + "," + args[1] + ")");
                outputDir = args[0];
                url = args[1];
            } else {
                logger.debug("main(" + args[0] + ")");
                outputDir = args[0];
            }
            DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyyMMdd");
            ZonedDateTime today = ZonedDateTime.now(JAPAN_ZONE_ID);
            String date = today.format(df);
            String thisMonthStr;
            int thisMonth = today.getMonthValue();
            if(thisMonth < 10) {
                thisMonthStr = today.getYear() + "0" + thisMonth;
            } else {
                thisMonthStr = today.getYear() + String.valueOf(thisMonth);
            }
            String nextMonthStr;
            int nextMonth = today.plusMonths(1).getMonthValue();
            if(nextMonth < 10) {
                nextMonthStr = today.plusMonths(1).getYear() + "0" + nextMonth;
            } else {
                nextMonthStr = today.plusMonths(1).getYear() + String.valueOf(nextMonth);
            }

            // 出力ファイル
            String output = outputDir + "/stop_list.txt";
            // メール送信先
            to = PropertyUtil.getValue("mail", "addr.to");

            // プロパティファイル読込
            int timeDifference = Integer.parseInt(PropertyUtil.getValue("karaage", "timedifference"));
            int importance = Integer.parseInt(PropertyUtil.getValue("karaage", "importance"));
            int beforeMin = Integer.parseInt(PropertyUtil.getValue("karaage", "before_min"));
            int afterMin = Integer.parseInt(PropertyUtil.getValue("karaage", "after_min"));
            int period = Integer.parseInt(PropertyUtil.getValue("karaage", "period"));

            // ヘッドレス
            System.setProperty("ui4j.headless", "true");

            // 設定
            PageConfiguration config = new PageConfiguration();
            config.setUserAgent("Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.82 Safari/537.36");

            // トップページを開く(今月)
            Page page;
            if(url == null) {
                page = BrowserFactory.getWebKit().navigate(URL + thisMonthStr + ".html", config);
            } else {
                page = BrowserFactory.getWebKit().navigate(url, config);
            }
            Document doc = page.getDocument();

            // 経済指標を取得
            List<EconomicIndicator> indicatorList = new ArrayList<EconomicIndicator>();
            DateTimeFormatter pageDt = DateTimeFormatter.ofPattern("yyyy/M/d H:mm");
            String announcementDate = null;

            Element tbody = doc.query("#calendar-table > tbody").get();
            List<Element> rows = tbody.getChildren();
            for(int i = 0; i < rows.size(); i++) {
                EconomicIndicator indicator = new EconomicIndicator();

                List<Element> columns = rows.get(i).getChildren();
                for(Element column : columns) {
                    String cls = column.getAttribute("class").get();
                    // 日付
                    if(cls.contains("cal-tbl-date")) {
                        String text = column.getText().get().trim();
                        if(text == null || text.length() == 0) {
                            continue;
                        }
                        announcementDate = text.substring(0, text.indexOf("("));
                    // 時間
                    } else if(cls.contains("cal-tbl-time")) {
                        String text = column.getText().get().trim();
                        if(text == null || text.length() == 0 || text.contains("*")) {
                            break;
                        }
                        LocalDateTime datetime = LocalDateTime.parse(
                                today.getYear() + "/" + announcementDate + " " + text, pageDt);    // この時点では日本時間
                        indicator.setAnnouncementDatetime(datetime.minusHours(timeDifference)); // MT4の時差を考慮
                    // 国、指標名
                    } else if(cls.contains("cal-tbl-event")) {
                        if(column.getChildren().size() == 0) {
                            continue;
                        }
                        String country = column.getChildren().get(0).getAttribute("title").get();
                        indicator.setCountry(country);
                        String text = column.getText().get().trim();
                        indicator.setName(text);
                    // 重要度
                    } else if(cls.contains("cal-tbl-important")) {
                        if(column.getChildren().size() == 0) {
                            break;
                        }
                        String starClass = column.getChildren().get(0).getClasses().get(1);
                        indicator.setImportance(Integer.parseInt(starClass.substring(starClass.indexOf("-") + 1)));
                        break;
                    }
                }

                indicatorList.add(indicator);
            }

            // トップページを開く(来月)
            if(url == null) {
                page = BrowserFactory.getWebKit().navigate(URL + nextMonthStr + ".html", config);
                doc = page.getDocument();

                tbody = doc.query("#calendar-table > tbody").get();
                rows = tbody.getChildren();
                for(int i = 0; i < rows.size(); i++) {
                    EconomicIndicator indicator = new EconomicIndicator();

                    List<Element> columns = rows.get(i).getChildren();
                    for(Element column : columns) {
                        String cls = column.getAttribute("class").get();
                        // 日付
                        if(cls.contains("cal-tbl-date")) {
                            String text = column.getText().get().trim();
                            if(text == null || text.length() == 0) {
                                continue;
                            }
                            announcementDate = text.substring(0, text.indexOf("("));
                        // 時間
                        } else if(cls.contains("cal-tbl-time")) {
                            String text = column.getText().get().trim();
                            if(text == null || text.length() == 0 || text.contains("*")) {
                                continue;
                            }
                            LocalDateTime datetime = LocalDateTime.parse(
                                    today.getYear() + "/" + announcementDate + " " + text, pageDt);    // この時点では日本時間
                            indicator.setAnnouncementDatetime(datetime.minusHours(timeDifference)); // MT4の時差を考慮
                        // 国、指標名
                        } else if(cls.contains("cal-tbl-event")) {
                            if(column.getChildren().size() == 0) {
                                continue;
                            }
                            String country = column.getChildren().get(0).getAttribute("title").get();
                            indicator.setCountry(country);
                            String text = column.getText().get().trim();
                            indicator.setName(text);
                        // 重要度
                        } else if(cls.contains("cal-tbl-important")) {
                            if(column.getChildren().size() == 0) {
                                continue;
                            }
                            String starClass = column.getChildren().get(0).getClasses().get(1);
                            indicator.setImportance(Integer.parseInt(starClass.substring(starClass.indexOf("-") + 1)));
                            break;
                        }
                    }

                    indicatorList.add(indicator);
                }
            }

            // 時間帯を統合
            List<LocalDateTime[]> startEndList = new ArrayList<LocalDateTime[]>();
            StringBuilder indicatorSubSb = new StringBuilder();
            int index = 0;
            for(EconomicIndicator indicator : indicatorList) {
                if(indicator.getAnnouncementDatetime() == null) {
                    continue;
                }

                LocalDateTime start = indicator.getAnnouncementDatetime().minusMinutes(beforeMin);
                LocalDateTime end = indicator.getAnnouncementDatetime().plusMinutes(afterMin);

                if(url == null && start.compareTo(today.toLocalDateTime().minusDays(1)) < 0) {
                    continue;
                }

                indicatorSubSb.append(start.plusHours(timeDifference).format(pageDt)).append(",")
                .append(end.plusHours(timeDifference).format(pageDt)).append(",")
                .append(indicator.getImportance()).append(",")
                .append(indicator.getName()).append("\r\n");

                // 重要度が指定未満の場合はスキップ
                if(indicator.getImportance() < importance) {
                    continue;
                }
                if(index == 0) {
                    LocalDateTime[] startEnd = new LocalDateTime[2];
                    startEnd[0] = start;
                    startEnd[1] = end;
                    startEndList.add(startEnd);
                } else {
                    LocalDateTime lastEnd = startEndList.get(startEndList.size() - 1)[1];
                    if(lastEnd.compareTo(start) < 0) {
                        LocalDateTime[] startEnd = new LocalDateTime[2];
                        startEnd[0] = start;
                        startEnd[1] = end;
                        startEndList.add(startEnd);
                    } else {
                        startEndList.get(startEndList.size() - 1)[1] = end;
                    }
                }
                index++;
            }

            // ファイル出力
            StringBuilder indicatorSb = new StringBuilder();
            for(LocalDateTime[] startEnd : startEndList) {
                LocalDateTime start = startEnd[0];
                LocalDateTime end = startEnd[1];

                if(today.plusDays(period + 1).getDayOfYear() < start.getDayOfYear()) {
                    break;
                }

                if(start.getDayOfMonth() == end.getDayOfMonth()) {
                    indicatorSb.append(toStr(start.getMonthValue())).append(toStr(start.getDayOfMonth())) // 月日
                    .append(toStr(start.getHour())).append(toStr(start.getMinute()))                      // 開始時刻
                    .append(toStr(end.getHour())).append(toStr(end.getMinute()))                          // 終了時刻
                    .append(",");
                } else {
                    indicatorSb.append(toStr(start.getMonthValue())).append(toStr(start.getDayOfMonth())) // 開始月日
                    .append(toStr(start.getHour())).append(toStr(start.getMinute()))                      // 開始時刻
                    .append("2359").append(",")                                                           // 当日最終時刻
                    .append(toStr(end.getMonthValue())).append(toStr(end.getDayOfMonth()))                // 終了月日
                    .append("0000")                                                                       // 翌日開始時刻
                    .append(toStr(end.getHour())).append(toStr(end.getMinute()))                          // 終了時刻
                    .append(",");
                }
            }

            System.out.println("経済指標時間");
            System.out.println(indicatorSb.toString());
            PrintWriter pw = new PrintWriter(new BufferedWriter(new FileWriter(new File(output))));
            pw.print(indicatorSb.toString());
            pw.close();

            System.out.println("経済指標時間(エクセル用)");
            System.out.println(indicatorSubSb.toString());
            MailUtil.send(to, date + "_経済指標時間", indicatorSubSb.toString(), output);

            // 正常終了
            logger.info("****************** END ******************");
            System.exit(0);
        } catch(Exception e) {
            logger.error("Failure.[" + counter + "]", e);
            if(counter++ < 10) {
                main(argsTmp);
            }
            MailUtil.send(to, "[ERROR] 経済指標時間", "経済指標時間取得エラー\r\n" + e.getLocalizedMessage());
            System.exit(1);
        }

    }

    /**
     * 月、時間、分を表す数値を文字列に変換します。
     *
     * @param time 時間、または分
     * @return 文字列
     */
    private static String toStr(int time) {
        if(time == 99) {
            return "00";
        }else if(time < 10) {
            return "0" + time;
        } else {
            return String.valueOf(time);
        }
    }

}
