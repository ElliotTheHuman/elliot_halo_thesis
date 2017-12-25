view: players {
  sql_table_name: halo_5_dataset.players ;;

  ############ JSON BLOBS ############

  dimension: gamertag_column {
    type: string
    sql: ${TABLE}.Gamertags ;;
    hidden: yes
  }

  dimension: results_column {
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
    sql: JSON_EXTRACT_SCALAR(${gamertag_column},"$.Gamertag") ;;
  }

  dimension: playlist_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results_column},"$.PlaylistId") ;;
  }

  dimension: rank_class {
    type: number
    sql: JSON_EXTRACT_SCALAR(${results_column},"$.Csr.DesignationId");;
  }

  dimension: rank_tier {
    type: number
    sql: JSON_EXTRACT_SCALAR(${results_column},"$.Csr.Tier") ;;
  }

  dimension: total_kills {
    type: number
    sql:  ;;
}

############ MEASURES ############

measure: count {
  type: count
}

}
