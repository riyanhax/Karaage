/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2015 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jp.co.studiogadget.exceloperation.loader.XlsxExcelFileLoader;
import jp.co.studiogadget.exceloperation.writer.XlsxExcelFileWriter;

/**
 * 時間が経済指標時間帯、マーケット時間帯に入っているか判断します。
 *
 * @author hidet
 *
 */
public class TimeChecker {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(TimeChecker.class);

    /** 日本のゾーンID */
    public static final ZoneId JAPAN_ZONE_ID = ZoneId.of("Asia/Tokyo");

    /**
     * メインメソッド。
     *
     * @param args エクセルファイルパス<br>
     *             対象シート
     * @throws Exception 例外
     */
    public static void main(String[] args) throws Exception {
        logger.info("***************** START *****************");
        if(args.length == 0) {
            System.out.print("TimeChecker.jar [excelPath] [sheetName] [default|summer]");
            System.exit(0);
        }
        String excelPath = args[0];
        String sheetName = args[1];
        String summer = args[2];

        XlsxExcelFileLoader loader = new XlsxExcelFileLoader(excelPath);

        // 経済指標時間帯を取得
        List<LocalDateTime[]> startEndList = new ArrayList<LocalDateTime[]>();
        for(int i = 0; true; i++) {
            String startStr = loader.getCellValue("経済指標時間帯", i + 1, 0);
            if(startStr == null || startStr.length() == 0) {
                break;
            }
            Date start = loader.getDateCellValue("経済指標時間帯", i + 1, 0);
            Date end = loader.getDateCellValue("経済指標時間帯", i + 1, 1);
            LocalDateTime[] startEnd = new LocalDateTime[2];
            startEnd[0] = LocalDateTime.ofInstant(start.toInstant(), JAPAN_ZONE_ID);
            startEnd[1] = LocalDateTime.ofInstant(end.toInstant(), JAPAN_ZONE_ID);
            startEndList.add(startEnd);
        }

        // マーケット時間帯を取得
        List<LocalTime[]> marketStartEndList = new ArrayList<LocalTime[]>();
        for(int i = 0; true; i++) {
            Date start;
            Date end;
            if("summer".equals(summer)) {
                String startStr = loader.getCellValue("マーケット時間帯", i + 2, 3);
                if(startStr == null || startStr.length() == 0) {
                    break;
                }
                start = loader.getDateCellValue("マーケット時間帯", i + 2, 3);
                end = loader.getDateCellValue("マーケット時間帯", i + 2, 4);
            } else {
                String startStr = loader.getCellValue("マーケット時間帯", i + 2, 1);
                if(startStr == null || startStr.length() == 0) {
                    break;
                }
                start = loader.getDateCellValue("マーケット時間帯", i + 2, 0);
                end = loader.getDateCellValue("マーケット時間帯", i + 2, 1);
            }
            LocalTime[] startEnd = new LocalTime[2];
            startEnd[0] = LocalDateTime.ofInstant(start.toInstant(), JAPAN_ZONE_ID).toLocalTime();
            startEnd[1] = LocalDateTime.ofInstant(end.toInstant(), JAPAN_ZONE_ID).toLocalTime();
            marketStartEndList.add(startEnd);
        }

        // Open日時を取得
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
        List<LocalDateTime> openDateTime = new ArrayList<LocalDateTime>();
        for(int i = 0; true; i++) {
            String chk = loader.getCellValue(sheetName, i + 6, 4);
            if(chk == null || chk.length() == 0) {
                break;
            }
            String day = loader.getCellValue(sheetName, i + 6, 5);
            String time = loader.getCellValue(sheetName, i + 6, 7).substring(11, 16);
            LocalDateTime open = LocalDateTime.parse(day + " " + time, df);
            openDateTime.add(open);
        }

        // 検証
        List<Integer> colors = new ArrayList<Integer>(); // 経済指標時間帯:1、マーケット時間帯:2、両方:3
        for(int i = 0; i < openDateTime.size(); i++) {
            LocalDateTime open  = openDateTime.get(i);
            colors.add(0);

            // 経済指標時間帯
            for(LocalDateTime[] startEnd : startEndList) {
                LocalDateTime start = startEnd[0];
                LocalDateTime end = startEnd[1];
                if(open.compareTo(start) < 0) {
                    break;
                }

                if(open.compareTo(start) >= 0 && open.compareTo(end) <= 0) {
                    colors.set(i, 1);
                    break;
                }
            }
            // マーケット時間帯
            for(LocalTime[] startEnd : marketStartEndList) {
                LocalTime start = startEnd[0];
                LocalTime end = startEnd[1];

                LocalTime openTime = open.toLocalTime();
                if(openTime.compareTo(start) >= 0 && openTime.compareTo(end) <= 0) {
                    if(colors.get(i) == 1) {
                        colors.set(i, 3);
                        break;
                    } else {
                        colors.set(i, 2);
                        break;
                    }
                }
            }
        }

        // 着色用の値を挿入
        XlsxExcelFileWriter writer = new XlsxExcelFileWriter(excelPath);
        for(int i = 0; i < colors.size(); i++) {
            int color = colors.get(i);
            writer.setValue(sheetName, i + 6, 20, color);
        }
        writer.write();

        // 正常終了
        logger.info("****************** END ******************");
        System.exit(0);
    }

}
