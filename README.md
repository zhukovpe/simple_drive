# Simple Drive

A Ruby on Rails REST API application that provides a unified interface for storing and retrieving blobs (files/data) using multiple storage backends including Amazon S3, PostgreSQL database, local filesystem, and FTP.

For requirements details check [requirements](docs/requirements)

## Installation

### Prerequisites

- Ruby 3.4.7 or compatible
- PostgreSQL database (docker setup [guide](docs/postgresql.md))

### Setup Instructions

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Set up the database**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```

3. **Add configuration**

   See `.env.sample` for example of environment variables configuration or check [configuration](#configuration) section for details.
   For "dotenv" usage just copy and put you values in:
   ```
   cp .env.sample .env
   ```

4. **Start the server**
   ```bash
   bundle exec rails server
   ```

   Verify the server is running by visiting: http://localhost:3000/up

## Configuration

The application have to be configured using environment variables.

- `SIMPLE_DRIVE_AUTH_TOKEN`: Bearer token for API authentication (required)
- `SIMPLE_DRIVE_STORAGE_TYPE`: Simple Drive storage type

#### Cloud Storage (S3 Compatible)
- `SIMPLE_DRIVE_STORAGE_TYPE=cloud`
- `SIMPLE_DRIVE_S3_BUCKET`: S3 bucket name
- `SIMPLE_DRIVE_AWS_KEY`: AWS access key ID
- `SIMPLE_DRIVE_AWS_SECRET`: AWS secret access key
- `SIMPLE_DRIVE_S3_REGION`: AWS region (e.g., `us-east-1`)

#### Local File System Storage
- `SIMPLE_DRIVE_STORAGE_TYPE=local`
- `SIMPLE_DRIVE_STORAGE_DIR`: Directory path for file storage (defaults to `tmp`)

#### FTP Storage
- `SIMPLE_DRIVE_STORAGE_TYPE=ftp`
- `SIMPLE_DRIVE_FTP_HOST`: FTP server hostname
- `SIMPLE_DRIVE_FTP_USER`: FTP username
- `SIMPLE_DRIVE_FTP_PASSWORD`: FTP password

## Running Tests

Run the full test suite:
```bash
bundle exec rspec
```

The test suite includes:
- Unit tests for models
- Request specs for API endpoints (integration)
- VCR cassettes for cloud storage tests

## Usage

### Authentication

All API requests require Bearer token authentication header:
```
Authorization: Bearer <your-auth-token>
```

### Store a Blob

**Endpoint:** `POST /v1/blobs`

**Request:**
```bash
curl -X POST http://localhost:3000/v1/blobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-auth-token" \
  -d '{
    "id": "my-unique-identifier",
    "data": "SGVsbG8gV29ybGQh"
  }'
```

**Request Body JSON:**
```json
{
  "id": "my-unique-identifier",
  "data": "SGVsbG8gV29ybGQh"
}
```

- `id`: A unique identifier for the blob (string, required)
- `data`: Base64-encoded binary data (string, required)

**Response:**
- `200 OK` - Blob stored successfully
- `400 Bad Request` - Invalid request (missing fields, invalid base64, etc.)
- `401 Unauthorized` - Missing or invalid authentication token

### Retrieve a Blob

**Endpoint:** `GET /v1/blobs/:id`

**Request:**
```bash
curl -X GET http://localhost:3000/v1/blobs/my-unique-identifier \
  -H "Authorization: Bearer your-auth-token"
```

**Response:**
- `200 OK` - Blob retrieved successfully
- `401 Unauthorized` - Missing or invalid authentication token
- `404 Not Found` - Blob with the specified ID does not exist

**Example Response:**
```json
{
  "id": "my-unique-identifier",
  "data": "SGVsbG8gV29ybGQh",
  "size": 11,
  "created_at": "2025-10-26T10:30:00Z"
}
```

- `id`: The unique identifier of the blob
- `data`: Base64-encoded blob data
- `size`: Size of the blob in bytes
- `created_at`: ISO 8601 timestamp of when the blob was created

**Encode & Decode base64 data:**
```bash
echo "Hello World" | base64
# Output: SGVsbG8gV29ybGQK
```

```bash
echo "SGVsbG8gU2ltcGxlIERyaXZlIQ==" | base64 -d
# Output: Hello Simple Drive!
```

## License

This project is part of a coding assessment/portfolio project.

## Contributing

This is a demonstration project. For questions or issues, please reach out to the maintainers.
