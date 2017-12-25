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
    sql_on: ${matches.primary_key_gamertag_playlistid} = ${players.primary_key_gamertag_playlistid} ;;
    relationship: many_to_one
  }

  join: metadata_playlists {
    sql_on: ${matches.playlist_id} = ${metadata_playlists.id}  ;;
    relationship: many_to_one
  }

  join: metadata_maps {
    sql_on: ${matches.map_id} = ${metadata_maps.id} ;;
    relationship: many_to_one
  }
}

explore: players {}

explore: metadata_playlists {}

explore: metadata_weapons {}

explore: metadata_maps {}
