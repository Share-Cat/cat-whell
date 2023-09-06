#[macro_use] extern crate rocket;
use rocket::{Data, data::ToByteUnit};

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[post("/", data = "<data>")]
async fn upload(data: Data<'_>) -> std::io::Result<String> {
    let mut file = data.open(128.kibibytes()).into_file("upload").await?;
    Ok(format!("Upload success"))

}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/", routes![index])
        .mount("/upload", routes![upload])
}