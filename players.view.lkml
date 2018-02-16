include: "*.view"

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

  dimension: rank_class_id {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Csr.DesignationId") AS INT64);;
  }

  dimension: total_games_completed {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalGamesCompleted") AS INT64) ;;
  }

  dimension: total_games_won {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalGamesWon") AS INT64) ;;
  }

  dimension: total_games_lost {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalGamesLost") AS INT64) ;;
  }

  dimension: rank_tier_id {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Csr.Tier") AS INT64) ;;
  }

  dimension: total_shots_fired_overall {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalShotsFired") AS FLOAT64);;
  }

  dimension: total_shots_landed_overall {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalShotsLanded") AS FLOAT64) ;;
  }

  dimension: accurary_overall {
    type: number
    sql: CASE WHEN ${total_shots_fired_overall} != 0 THEN ${total_shots_landed_overall}/${total_shots_fired_overall}
              ELSE 0
              END;;
    value_format_name: percent_2
  }

  dimension: total_kills {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalKills") AS INT64) ;;
  }

  dimension: total_assists {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalAssists") AS INT64) ;;
  }

  dimension: total_deaths {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalDeaths") AS INT64) ;;
  }

  dimension: total_headshots {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalHeadshots") AS INT64) ;;
  }

  dimension: total_weapon_damage {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.TotalWeaponDamage") AS FLOAT64) ;;
  }

  dimension: weapon_with_most_kills_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.WeaponWithMostKills.WeaponId.StockId") ;;
  }

  dimension: total_kills_with_weapon_with_most_kills {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.WeaponWithMostKills.TotalKills") AS INT64) ;;
  }

  dimension: total_damage_with_weapon_with_most_kills {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.WeaponWithMostKills.TotalDamageDealt") AS INT64) ;;
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

  dimension: win_percentage {
    type: number
    sql: ${total_games_won}/${total_games_completed} ;;
    value_format_name: percent_2
  }



############ MEASURES ############

measure: count {
  type: count
}

measure: percent_of_total {
  type: percent_of_total
  sql: ${count} ;;

  drill_fields: [players.gamertag]
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

measure: average_win_percentage {
  type: average
  sql: ${win_percentage} ;;
  value_format_name: percent_2
}

}
