include: "*.view.lkml"

view: matches_sessions {
  derived_table: {

    sql: SELECT {% parameter test_param %};;

      persist_for: "24 hours"
  }

  parameter: test_param {
    type: string
  }

  dimension: test_dim {
    type: string
    sql: 'test' ;;
  }
}
