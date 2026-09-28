import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { randomUUID } from "crypto";

const s3 = new S3Client({});
const BUCKET = process.env.S3_BUCKET;
const PREFIX = process.env.UPLOAD_PREFIX || "uploads/";

export const handler = async (event) => {
  try {
    let bodyBuffer;
    let contentType = event.headers?.["content-type"] || "image/jpeg";

    if (event.isBase64Encoded) {
      bodyBuffer = Buffer.from(event.body, "base64");
    } else {
      bodyBuffer = Buffer.from(event.body || "", "utf-8");
    }

    if (bodyBuffer.length > 10 * 1024 * 1024) {
      return {
        statusCode: 413,
        body: JSON.stringify({ message: "Payload supera el maximo permitido de 10 MB" }),
      };
    }

    const key = `${PREFIX}${randomUUID()}.jpg`;

    await s3.send(
      new PutObjectCommand({
        Bucket: BUCKET,
        Key: key,
        Body: bodyBuffer,
        ContentType: contentType,
      })
    );

    return {
      statusCode: 201,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message: "Imagen cargada con exito",
        bucket: BUCKET,
        key: key,
      }),
    };
  } catch (err) {
    console.error("Error en upload-lambda:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Error interno al procesar imagen" }),
    };
  }
};