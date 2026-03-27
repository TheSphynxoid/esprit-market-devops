#!/bin/bash
set -e

echo "========================================"
echo "  Generate TypeScript Types from API"
echo "========================================"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEVOPS_ROOT="$(dirname "$SCRIPT_DIR")"
WORKSPACE_ROOT="$(dirname "$DEVOPS_ROOT")"
API_TYPES_DIR="$DEVOPS_ROOT/shared/api-types"
OPENAPI_FILE="$API_TYPES_DIR/openapi.yaml"

echo "Workspace root: $WORKSPACE_ROOT"
echo "DevOps root: $DEVOPS_ROOT"

# Check if backend is running
echo ""
echo "Checking if backend is running..."
if ! curl -s http://localhost:8088/actuator/health > /dev/null 2>&1; then
    echo "ERROR: Backend is not running on port 8088"
    echo ""
    echo "Please start the backend first:"
    echo "  cd $WORKSPACE_ROOT/backend && ./mvnw spring-boot:run"
    echo ""
    echo "Or start with docker compose:"
    echo "  docker compose -f $DEVOPS_ROOT/docker-compose.yml -f $DEVOPS_ROOT/docker-compose.dev.yml up -d backend"
    exit 1
fi

echo "✓ Backend is running"

# Fetch OpenAPI spec
echo ""
echo "Fetching OpenAPI specification..."
curl -s http://localhost:8088/v3/api-docs -o "$OPENAPI_FILE"
echo "✓ OpenAPI spec saved to: $OPENAPI_FILE"

# Check if openapi-generator-cli is available
if ! command -v openapi-generator-cli &> /dev/null; then
    echo ""
    echo "openapi-generator-cli not found, installing..."
    npm install -g @openapitools/openapi-generator-cli
fi

# Ensure output directory exists
mkdir -p "$API_TYPES_DIR/src/generated"

# Generate TypeScript types
echo ""
echo "Generating TypeScript types..."
cd "$API_TYPES_DIR"

openapi-generator-cli generate \
    -i "$OPENAPI_FILE" \
    -g typescript-angular \
    -o src/generated \
    --additional-properties=ngVersion=17.0.0,npmName=@esprit-market/api-types,supportsES6=true,withInterfaces=true

echo "✓ TypeScript types generated in: $API_TYPES_DIR/src/generated"

# Create index.ts barrel file
cat > src/generated/index.ts << 'EOF'
// Auto-generated API types - DO NOT EDIT
export * from './model/models';
export * from './api/api.module';
EOF

echo ""
echo "========================================"
echo "  Generation Complete!"
echo "========================================"
echo ""
echo "Generated files:"
echo "  $API_TYPES_DIR/src/generated/"
echo ""
echo "Usage in frontend:"
echo '  import { ProductResponse } from "@esprit-market/api-types";'
echo ""
