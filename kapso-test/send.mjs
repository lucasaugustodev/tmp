import { WhatsAppClient } from "@kapso/whatsapp-cloud-api";

const whatsapp = new WhatsAppClient({
  baseUrl: "https://api.kapso.ai/meta/whatsapp",
  kapsoApiKey: "88d2b65b02c6531e71295e25dad846ba3b5c10391c85f0b109b7a8625e1909d3",
});

try {
  const result = await whatsapp.messages.sendText({
    phoneNumberId: "934584499749015",
    to: "553173598865",
    body: "Oi! Aqui é o Claude Code respondendo sua mensagem direto do terminal. Funcionou!",
  });
  console.log("SUCCESS:", JSON.stringify(result, null, 2));
} catch (err) {
  console.error("ERROR:", err.message);
  if (err.response) {
    console.error("Response:", JSON.stringify(err.response, null, 2));
  }
  console.error("Full error:", err);
}
