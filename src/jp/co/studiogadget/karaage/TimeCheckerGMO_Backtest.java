/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2015 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 時間が経済指標時間帯、マーケット時間帯に入っているか判断します。
 *
 * @author hidet
 *
 */
public class TimeCheckerGMO_Backtest {
    /** ロガー */
    private static Logger logger = LoggerFactory.getLogger(TimeCheckerGMO_Backtest.class);

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
            System.out.print("TimeCheckerGMO_Backtest.jar [csvPath] [inutPath]");
            System.exit(0);
        }
        String csvPath = args[0];
        String inPath = args[1];

        SimpleDateFormat df = new SimpleDateFormat("yyyy/M/d HH:mm");

        // 経済指標時間帯を取得
        logger.info("Loading...[" + csvPath + "]");
        List<LocalDateTime[]> startEndList = new ArrayList<LocalDateTime[]>();
        List<Integer> starList = new ArrayList<Integer>();
        int index = 0;
        try(BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(csvPath), "SJIS"))) {
            while(true) {
                String line = br.readLine();
                if(StringUtils.isBlank(line)) {
                    br.close();
                    break;
                }

                String[] columns = line.split(",");
                Date before1 = df.parse(columns[0]);
                Date after1 = df.parse(columns[1]);
                Date before2 = df.parse(columns[4]);
                Date after2 = df.parse(columns[5]);
                Date before3 = df.parse(columns[6]);
                Date after3 = df.parse(columns[7]);
                Date zero = df.parse(columns[8]);
                int star = Integer.parseInt(columns[2]);

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
                System.out.println(++index);
            }
        }

        // Open日時を取得
        logger.info("Loading...[" + inPath + "]");
        SimpleDateFormat odf = new SimpleDateFormat("yyyy/MM/dd HH:mm");
        List<LocalDateTime> openDateTime = new ArrayList<LocalDateTime>();
        index = 0;
        try(BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(inPath), "SJIS"))) {
            while(true) {
                String line = br.readLine();
                if(StringUtils.isBlank(line)) {
                    br.close();
                    break;
                }

                Date open = odf.parse(line);
                openDateTime.add(LocalDateTime.ofInstant(open.toInstant(), JAPAN_ZONE_ID));
                System.out.println(++index);
            }
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

        // 値を出力
        PrintWriter pw = new PrintWriter(
                new BufferedWriter(new FileWriter(new File(inPath.replace(".txt", "_re.txt")), false)));
        for(int i = 0; i < colors.size(); i++) {
            int color = colors.get(i);
            int star = stars.get(i);
            if(star == 99) {
                pw.println(color + "\t");
            } else {
                pw.println(color + "\t" + star);
            }
        }
        pw.close();

        // 正常終了
        logger.info("****************** END ******************");
        System.exit(0);
    }

}
