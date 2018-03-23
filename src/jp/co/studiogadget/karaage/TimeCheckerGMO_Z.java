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
public class TimeCheckerGMO_Z {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(TimeCheckerGMO_Z.class);

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
            System.out.print("TimeChecker.jar [excelPath] [sheetName] [economicIndicatorsExcelPath]");
            System.exit(0);
        }
        String excelPath = args[0];
        String sheetName = args[1];
        String ecExcelPath = args[2];

        XlsxExcelFileLoader ecLoader = new XlsxExcelFileLoader(ecExcelPath);

        // 経済指標時間帯を取得
        DateTimeFormatter df1 = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
        List<LocalDateTime[]> startEndList = new ArrayList<LocalDateTime[]>();
        List<Integer> starList = new ArrayList<Integer>();
        for(int i = 0; true; i++) {
            String startStr = ecLoader.getCellValue("ALL", i, 0);
            if(startStr == null || startStr.length() == 0) {
                break;
            }
            String before1 = ecLoader.getCellValue("ALL", i, 6);
            String after1 = ecLoader.getCellValue("ALL", i, 7);
            String before2 = ecLoader.getCellValue("ALL", i, 8);
            String after2 = ecLoader.getCellValue("ALL", i, 9);
            String before3 = ecLoader.getCellValue("ALL", i, 10);
            String after3 = ecLoader.getCellValue("ALL", i, 11);
            String before4 = ecLoader.getCellValue("ALL", i, 12);
            String after4 = ecLoader.getCellValue("ALL", i, 13);
            String zero = ecLoader.getCellValue("ALL", i, 14);
            int star = (int) Double.parseDouble(ecLoader.getCellValue("ALL", i, 4));
            LocalDateTime[] startEnd = new LocalDateTime[9];
            startEnd[0] = LocalDateTime.parse(before1, df1);
            startEnd[1] = LocalDateTime.parse(after1, df1);
            startEnd[2] = LocalDateTime.parse(before2, df1);
            startEnd[3] = LocalDateTime.parse(after2, df1);
            startEnd[4] = LocalDateTime.parse(before3, df1);
            startEnd[5] = LocalDateTime.parse(after3, df1);
            startEnd[6] = LocalDateTime.parse(before4, df1);
            startEnd[7] = LocalDateTime.parse(after4, df1);
            startEnd[8] = LocalDateTime.parse(zero, df1);
            startEndList.add(startEnd);
            starList.add(star);
            System.out.println(i);
        }

        // Open日時を取得
        XlsxExcelFileLoader loader = new XlsxExcelFileLoader(excelPath);
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        List<LocalDateTime> openDateTime = new ArrayList<LocalDateTime>();
        int lastIndex = -1;
        for(int i = 0; true; i++) {
            String chk = loader.getCellValue(sheetName, i + 8, 1);
            if(chk == null || chk.length() == 0) {
                break;
            }
            String chk2 = loader.getCellValue(sheetName, i + 8, 8);
            if(chk2 != null && chk2.length() > 0) {
                lastIndex = i;
                continue;
            }

            String day = loader.getStringCellValue(sheetName, i + 8, 6);
            String time = loader.getStringCellValue(sheetName, i + 8, 7);
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
                LocalDateTime before4 = startEnd[6];
                LocalDateTime after4 = startEnd[7];
                LocalDateTime zero = startEnd[8];
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
                if(open.compareTo(before4) > 0 && open.compareTo(before3) <= 0) {
                    colors.set(i, -4);
                    stars.set(i, star);
                    break;
                }
                if(open.compareTo(after3) >= 0 && open.compareTo(after4) < 0) {
                    colors.set(i, 4);
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
            writer.setValue(sheetName, lastIndex + 1 + i + 8, 8, color);
            if(star == 99) {
                writer.setValue(sheetName, lastIndex + 1 + i + 8, 9, "");
            } else {
                writer.setValue(sheetName, lastIndex + 1 + i + 8, 9, star);
            }
        }
        writer.write();

        // 正常終了
        logger.info("****************** END ******************");
        System.exit(0);
    }

}
