connection: "halo_database_1"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

datagroup: elliot_halo_thesis_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: elliot_halo_thesis_default_datagroup

explore: matches {
  join: players {
    type: left_outer
    sql_on: ${matches.gamertag} = ${players.gamertag} AND ${matches.playlist_id} = ${players.playlist_id} ;;
    relationship: many_to_one
  }
}

explore: players {}
