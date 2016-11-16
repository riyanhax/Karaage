/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2015 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.time.LocalDateTime;
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
public class TimeCheckerGMO_G {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(TimeCheckerGMO_G.class);

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
        List<Integer> starList = new ArrayList<Integer>();
        for(int i = 0; true; i++) {
            String startStr = loader.getCellValue("経済指標時間帯", i + 1, 0);
            if(startStr == null || startStr.length() == 0) {
                break;
            }
            Date before1 = loader.getDateCellValue("経済指標時間帯", i + 1, 0);
            Date after1 = loader.getDateCellValue("経済指標時間帯", i + 1, 1);
            Date before2 = loader.getDateCellValue("経済指標時間帯", i + 1, 4);
            Date after2 = loader.getDateCellValue("経済指標時間帯", i + 1, 5);
            Date before3 = loader.getDateCellValue("経済指標時間帯", i + 1, 6);
            Date after3 = loader.getDateCellValue("経済指標時間帯", i + 1, 7);
            Date zero = loader.getDateCellValue("経済指標時間帯", i + 1, 8);
            int star = (int) Double.parseDouble(loader.getCellValue("経済指標時間帯", i + 1, 2));
            LocalDateTime[] startEnd = new LocalDateTime[7];
            startEnd[0] = LocalDateTime.ofInstant(before1.toInstant(), JAPAN_ZONE_ID);
            startEnd[1] = LocalDateTime.ofInstant(after1.toInstant(), JAPAN_ZONE_ID);
            startEnd[2] = LocalDateTime.ofInstant(before2.toInstant(), JAPAN_ZONE_ID);
            startEnd[3] = LocalDateTime.ofInstant(after2.toInstant(), JAPAN_ZONE_ID);
            startEnd[4] = LocalDateTime.ofInstant(before3.toInstant(), JAPAN_ZONE_ID);
            startEnd[5] = LocalDateTime.ofInstant(after3.toInstant(), JAPAN_ZONE_ID);
            startEnd[6] = LocalDateTime.ofInstant(zero.toInstant(), JAPAN_ZONE_ID);
            startEndList.add(startEnd);
            starList.add(star);
            System.out.println(i);
        }

        // Open日時を取得
        DateTimeFormatter df = DateTimeFormatter.ofPattern("MM-dd-yyyy H:m");
        List<LocalDateTime> openDateTime = new ArrayList<LocalDateTime>();
        int lastIndex = -1;
        for(int i = 0; true; i++) {
            String chk = loader.getCellValue(sheetName, i + 8, 0);
            if(chk == null || chk.length() == 0) {
                break;
            }
            String chk2 = loader.getCellValue(sheetName, i + 8, 29);
            if(chk2 != null && chk2.length() > 0) {
                lastIndex = i;
                continue;
            }

            String day = loader.getCellValue(sheetName, i + 8, 9).substring(0, 10);
            String time = loader.getCellValue(sheetName, i + 8, 9).substring(13, 21);
            time = time.substring(time.lastIndexOf(":") - 5, time.lastIndexOf(":"));
            LocalDateTime open = LocalDateTime.parse(day + " " + time, df);
            openDateTime.add(open);
            System.out.println(i);
        }

        // 検証
        List<Integer> colors = new ArrayList<Integer>(); // 経済指標時間帯
        List<Integer> stars = new ArrayList<Integer>();   // 経済指標重要度
        for(int i = 0; i < openDateTime.size(); i++) {
            LocalDateTime open  = openDateTime.get(i);
            colors.add(0);
            stars.add(99);

            // 経済指標時間帯
            int idx = 0;
            for(LocalDateTime[] startEnd : startEndList) {
                LocalDateTime before1 = startEnd[0];
                LocalDateTime after1 = startEnd[1];
                LocalDateTime before2 = startEnd[2];
                LocalDateTime after2 = startEnd[3];
                LocalDateTime before3 = startEnd[4];
                LocalDateTime after3 = startEnd[5];
                LocalDateTime zero = startEnd[6];
                int star = starList.get(idx++);

                if(open.compareTo(before1) > 0 && open.compareTo(zero) < 0) {
                    colors.set(i, -1);
                    stars.set(i, star);
                    break;
                }
                if(open.compareTo(zero) >= 0 && open.compareTo(after1) < 0) {
                    colors.set(i, 1);
                    stars.set(i, star);
                    break;
                }
                if(open.compareTo(before2) > 0 && open.compareTo(before1) <= 0) {
                    colors.set(i, -2);
                    stars.set(i, star);
                    break;
                }
                if(open.compareTo(after1) >= 0 && open.compareTo(after2) < 0) {
                    colors.set(i, 2);
                    stars.set(i, star);
                    break;
                }
                if(open.compareTo(before3) > 0 && open.compareTo(before2) <= 0) {
                    colors.set(i, -3);
                    stars.set(i, star);
                    break;
                }
                if(open.compareTo(after2) >= 0 && open.compareTo(after3) < 0) {
                    colors.set(i, 3);
                    stars.set(i, star);
                    break;
                }
            }
        }

        // 着色用の値を挿入
        XlsxExcelFileWriter writer = new XlsxExcelFileWriter(excelPath);
        for(int i = 0; i < colors.size(); i++) {
            int color = colors.get(i);
            int star = stars.get(i);
            writer.setValue(sheetName, lastIndex + 1 + i + 8, 29, color);
            if(star == 99) {
                writer.setValue(sheetName, lastIndex + 1 + i + 8, 30, "");
            } else {
                writer.setValue(sheetName, lastIndex + 1 + i + 8, 30, star);
            }
        }
        writer.write();

        // 正常終了
        logger.info("****************** END ******************");
        System.exit(0);
    }

}
