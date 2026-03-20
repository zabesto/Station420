export default {
	async fetch(request, env) {
		const response = await env.ASSETS.fetch(request);
		const url = new URL(request.url);
		if (!url.pathname.endsWith(".wasm")) {
			return response;
		}

		const headers = new Headers(response.headers);
		headers.set("Content-Encoding", "gzip");
		headers.set("Content-Type", "application/wasm");
		headers.delete("Content-Length");

		return new Response(response.body, {
			status: response.status,
			statusText: response.statusText,
			headers,
		});
	},
};
