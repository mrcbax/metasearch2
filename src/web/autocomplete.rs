use std::collections::HashMap;

use axum::{extract::Query, http::StatusCode, response::IntoResponse, Json};

use crate::engines;

pub async fn route(Query(params): Query<HashMap<String, String>>) -> impl IntoResponse {
    let query = params
        .get("q")
        .cloned()
        .unwrap_or_default()
        .replace('\n', " ");

    let res = match engines::autocomplete(&query).await {
        Ok(res) => res,
        Err(err) => {
            eprintln!("Autocomplete error for {query}: {err}");
            return (StatusCode::INTERNAL_SERVER_ERROR, Json((query, vec![])));
        }
    };

    (StatusCode::OK, Json((query, res)))
}
