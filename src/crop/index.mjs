import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({});
const BUCKET = process.env.S3_BUCKET;
const PROCESSED_PREFIX = process.env.PROCESSED_PREFIX || "processed/";

export const handler = async (event) => {
  const batchItemFailures = [];

  for (const record of event.Records) {
    try {
      const sqsBody = JSON.parse(record.body);
      
      if (sqsBody.Records) {
        for (const s3Record of sqsBody.Records) {
          const key = decodeURIComponent(s3Record.s3.object.key.replace(/\+/g, " "));
          console.log(`Procesando archivo: ${key}`);

          const fileName = key.split("/").pop().split(".")[0];
          const outputKey = `${PROCESSED_PREFIX}${fileName}_circular.png`;

          await s3.send(
            new PutObjectCommand({
              Bucket: BUCKET,
              Key: outputKey,
              Body: Buffer.from("mock-processed-40x40-png"),
              ContentType: "image/png",
            })
          );
        }
      }
    } catch (error) {
      console.error(`Error procesando mensaje SQS ${record.messageId}:`, error);
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures };
};