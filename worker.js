export default {
	async fetch(request, env) {
		const url = new URL(request.url);
		if (!url.pathname.endsWith(".wasm")) {
			const response = await env.ASSETS.fetch(request);
			return response;
		}

		const gzUrl = new URL(url);
		gzUrl.pathname = `${url.pathname}.gz`;
		const assetRequest = new Request(gzUrl.toString(), request);
		const response = await env.ASSETS.fetch(assetRequest);
		const headers = new Headers(response.headers);
		headers.set("Content-Encoding", "gzip");
		headers.set("Content-Type", "application/wasm");
		headers.delete("Content-Length");
		headers.set("Cache-Control", "public, max-age=31536000, immutable");

		return new Response(response.body, {
			status: response.status,
			statusText: response.statusText,
			headers,
		});
	},
};
