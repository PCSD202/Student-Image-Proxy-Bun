const BASE_PATH = "/public";
const apiKey = process.env.API_KEY || "YOUR_API_KEY";

const server = Bun.serve({
    static: {
        // health-check endpoint
        "/api/health-check": new Response("I'm awake!"),
    },
    async fetch(req) {
        // API Key validation
        const requestApiKey = req.headers.get("x-api-key");
        if (requestApiKey !== apiKey) {
            return new Response("Unauthorized", { status: 401 });
        }
        
        const url = new URL(req.url);

        const filename = url.pathname.substring(1); // Remove leading "/"
        const f = Bun.file(BASE_PATH +'/'+ filename + '.jpg');
        return new Response(f);
    },
    error() {
        return new Response('Not Found', { status: 404 });
    },
  });

console.log(`Listening on: ${server.url}`);