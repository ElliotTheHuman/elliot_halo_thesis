view: players {
  sql_table_name: halo_5_dataset.players ;;

  ############ JSON BLOBS ############

  dimension: gamertags {
    type: string
    sql: ${TABLE}.Gamertags ;;
    hidden: yes
  }

  dimension: results {
    type: string
    sql: ${TABLE}.Results ;;
    hidden: yes
  }

  ############ DIMENSIONS ############

  # HELP ME COMPOUND PRIMARY KEY, YOU'RE MY ONLY HOPE
  # (GURU CARD: https://discourse.looker.com/t/how-can-i-use-compound-primary-keys-in-looker/310)

  dimension: primary_key_gamertag_playlistid {
    primary_key:yes
    hidden: yes
    sql: CONCAT(${gamertag},' ',${playlist_id}) ;;
  }

  dimension: gamertag {
    type: string
    sql: JSON_EXTRACT_SCALAR(${gamertags},"$.Gamertag") ;;
  }

  dimension: playlist_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.PlaylistId") ;;
  }

  dimension: rank_class {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Csr.DesignationId") AS INT64);;
  }

  dimension: rank_tier {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Csr.Tier") AS INT64) ;;
  }

  dimension: total_shots_fired_overall {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalShotsFired") AS FLOAT64);;
    hidden: yes
  }

  dimension: total_shots_landed_overall {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalShotsLanded") AS FLOAT64) ;;
    hidden: yes
  }

  dimension: accurary_overall {
    type: number
    sql: CASE WHEN ${total_shots_fired_overall} != 0 THEN ${total_shots_landed_overall}/${total_shots_fired_overall}
              ELSE 0
              END;;
    value_format_name: percent_2
  }

  dimension: weapon_with_most_kills_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.WeaponWithMostKills.WeaponId.StockId") ;;
  }

  dimension: total_shots_fired_weapon_with_most_kills {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.WeaponWithMostKills.TotalShotsFired") AS FLOAT64) ;;
    hidden: yes
  }

  dimension: total_shots_landed_weapon_with_most_kills {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.WeaponWithMostKills.TotalShotsLanded") AS FLOAT64) ;;
    hidden: yes
  }

  dimension: accuracy_weapon_with_most_kills {
    type: number
    sql: CASE WHEN ${total_shots_fired_weapon_with_most_kills} != 0 THEN ${total_shots_landed_weapon_with_most_kills}/${total_shots_fired_weapon_with_most_kills}
              ELSE 0
              END;;
  }

############ MEASURES ############

measure: count {
  type: count
}

measure: average_accuracy_overall {
  type: average
  sql: ${accurary_overall} ;;
  value_format_name: percent_2
}

measure: average_accuracy_weapon_with_most_kills {
  type: average
  sql: ${accuracy_weapon_with_most_kills} ;;
  value_format_name: percent_2
}

measure: percent_of_total {
  type: percent_of_total
  sql: ${count} ;;
}

}
