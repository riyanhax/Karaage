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
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jp.co.studiogadget.exceloperation.loader.XlsxExcelFileLoader;

/**
 * 時間が経済指標時間帯、マーケット時間帯に入っているか判断します。
 *
 * @author hidet
 *
 */
public class TimeCheckerGMO2 {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(TimeCheckerGMO2.class);

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
            Date after = loader.getDateCellValue("経済指標時間帯", i + 1, 4);
            Date after2 = loader.getDateCellValue("経済指標時間帯", i + 1, 5);
            LocalDateTime[] startEnd = new LocalDateTime[4];
            startEnd[0] = LocalDateTime.ofInstant(start.toInstant(), JAPAN_ZONE_ID);
            startEnd[1] = LocalDateTime.ofInstant(end.toInstant(), JAPAN_ZONE_ID);
            startEnd[2] = LocalDateTime.ofInstant(after.toInstant(), JAPAN_ZONE_ID);
            startEnd[3] = LocalDateTime.ofInstant(after2.toInstant(), JAPAN_ZONE_ID);
            startEndList.add(startEnd);
        }

        Map<String, List<Integer>> colorsMap = new HashMap<String, List<Integer>>();
        for(int j = 0; j < 16; j++) {
            // Open日時を取得
            DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
            List<LocalDateTime> openDateTime = new ArrayList<LocalDateTime>();
            String symbol = loader.getCellValue(sheetName, 0, j * 3);
            for(int i = 0; true; i++) {
                String chk = loader.getCellValue(sheetName, i + 2, j * 3);
                if(chk == null || chk.length() == 0) {
                    break;
                }

                String day = loader.getCellValue(sheetName, i + 2, j * 3);
                String time = loader.getCellValue(sheetName, i + 2, j * 3 + 1);
                time = time.substring(time.lastIndexOf(":") - 5, time.lastIndexOf(":"));
                LocalDateTime open = LocalDateTime.parse(day + " " + time, df);
                openDateTime.add(open);
            }

            // 検証
            List<Integer> colors = new ArrayList<Integer>();
            for(int i = 0; i < openDateTime.size(); i++) {
                LocalDateTime open  = openDateTime.get(i);
                colors.add(0);

                // 経済指標時間帯
                for(LocalDateTime[] startEnd : startEndList) {
                    LocalDateTime start = startEnd[0];
                    LocalDateTime end = startEnd[1];
                    LocalDateTime after = startEnd[2];
                    LocalDateTime after2 = startEnd[3];
                    if(open.compareTo(start) >= 0 && open.compareTo(end) <= 0) {
                        colors.set(i, 1);
                        break;
                    }

                    if(open.compareTo(start) >= 0 && open.compareTo(after) <= 0) {
                        colors.set(i, 2);
                        break;
                    }

                    if(open.compareTo(start) >= 0 && open.compareTo(after2) <= 0) {
                        colors.set(i, 3);
                        break;
                    }
                }
            }
            colorsMap.put(symbol, colors);

        }

        // 着色用の値を挿入
        for(String symbol : colorsMap.keySet()) {
            List<Integer> colors = colorsMap.get(symbol);
            PrintWriter pw = new PrintWriter(
                    new BufferedWriter(new FileWriter(new File(excelPath.replace(".xlsx", "_" + symbol + ".txt")), false)));
            for(int i = 0; i < colors.size(); i++) {
                int color = colors.get(i);
                pw.println(color);
            }
            pw.close();
        }

        // 正常終了
        logger.info("****************** END ******************");
        System.exit(0);
    }

}
