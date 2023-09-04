use std::convert::Infallible;
use std::net::SocketAddr;

use http_body_util::Full;
use http_body_util::Empty;
use hyper::body::Bytes;
use hyper::server::conn::http1;
use hyper::service::service_fn;
use hyper::{Request, Response};
use hyper_util::rt::TokioIo;
use tokio::net::TcpListener;
use hyper::body::Frame;
use hyper::{Method, StatusCode};
use http_body_util::{combinators::BoxBody, BodyExt};

struct Returndata {
    data: String,
    iserror: bool,
}

async fn whell(
    req: Request<hyper::body::Incoming>,
) -> Result<Response<BoxBody<Bytes, hyper::Error>>, hyper::Error> {
    match (req.method(), req.uri().path()) {
        (&Method::GET, "/") => Ok(Response::new(full("Try POSTing data to /echo"))),
        (&Method::POST, "/runcommand") => {
            //from body get json,
            // command in json.command
            // run command

            let data = vec!["foo", "bar"];
            let res = match serde_json::to_string(&data) {
                Ok(res) => res,
                Err(e) => {
                    let mut error = Response::new(full(e.to_string()));
                    *error.status_mut() = StatusCode::INTERNAL_SERVER_ERROR;
                    return Ok(error);
                }
            };

            let mut returndata = runcommand(res).await;
            if returndata.iserror {
                let mut error = Response::new(full(returndata.data));
                *error.status_mut() = StatusCode::INTERNAL_SERVER_ERROR;
                Ok(error)
            } else {
                Ok(Response::new(full(returndata.data)))
            }
        }
        

        _ => {
            let mut not_found = Response::new(empty());
            *not_found.status_mut() = StatusCode::NOT_FOUND;
            Ok(not_found)
        }
    }
}

async fn runcommand(command: String) -> Returndata {
    let mut returndata = Returndata {
        data: String::from(""),
        iserror: false,
    };
    let output = std::process::Command::new("sh")
        .arg("-c")
        .arg(command)
        .output()
        .expect("failed to execute process");
    if output.status.success() {
        returndata.data = String::from_utf8_lossy(&output.stdout).to_string();
    } else {
        returndata.data = String::from_utf8_lossy(&output.stderr).to_string();
        returndata.iserror = true;
    }
    return returndata;
}

fn empty() -> BoxBody<Bytes, hyper::Error> {
    Empty::<Bytes>::new()
        .map_err(|never| match never {})
        .boxed()
}
fn full<T: Into<Bytes>>(chunk: T) -> BoxBody<Bytes, hyper::Error> {
    Full::new(chunk.into())
        .map_err(|never| match never {})
        .boxed()
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));

    let listener = TcpListener::bind(addr).await?;
    println!("Listening on http://{}", addr);
    loop {
        let (stream, _) = listener.accept().await?;
        let io = TokioIo::new(stream);

        tokio::task::spawn(async move {
            if let Err(err) = http1::Builder::new()
                .serve_connection(io, service_fn(whell))
                .await
            {
                println!("Error serving connection: {:?}", err);
            }
        });
    }
}
