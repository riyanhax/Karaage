/*
 * 株式会社スタジオガジェット
 * Copyright(C) 2015 Studiogadget Inc.
 *
 */
package jp.co.studiogadget.karaage.param;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 経済指標を表現するクラス。
 *
 * @author hidet
 *
 */
public class EconomicIndicator implements Serializable {
    /** シリアルバージョンID */
    private static final long serialVersionUID = 1L;

    /** 指標名 */
    private String name;

    /** 発表日時(MT4タイムゾーン) */
    private LocalDateTime announcementDatetime;

    /** 国 */
    private String country;

    /** 重要度 */
    private int importance;


    /**
     * 指標名を取得します。
     *
     * @return 指標名
     */
    public String getName() {
        return name;
    }


    /**
     * 指標名を設定します。
     *
     * @param name 指標名
     */
    public void setName(String name) {
        this.name = name;
    }


    /**
     * 発表日時(MT4タイムゾーン)を取得します。
     *
     * @return 発表日時(MT4タイムゾーン)
     */
    public LocalDateTime getAnnouncementDatetime() {
        return announcementDatetime;
    }


    /**
     * 発表日時(MT4タイムゾーン)を設定します。
     *
     * @param announcementDatetime 発表日時(MT4タイムゾーン)
     */
    public void setAnnouncementDatetime(LocalDateTime announcementDatetime) {
        this.announcementDatetime = announcementDatetime;
    }


    /**
     * 国を取得します。
     *
     * @return 国
     */
    public String getCountry() {
        return country;
    }


    /**
     * 国を設定します。
     *
     * @param country 国
     */
    public void setCountry(String country) {
        this.country = country;
    }


    /**
     * 重要度を取得します。
     *
     * @return 重要度
     */
    public int getImportance() {
        return importance;
    }


    /**
     * 重要度を設定します。
     *
     * @param importance 重要度
     */
    public void setImportance(int importance) {
        this.importance = importance;
    }


}
