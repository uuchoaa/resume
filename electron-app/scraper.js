// Script injetado em W1 para fazer scraping do chat do LinkedIn
// Este script roda no contexto da página (W1)

(async () => {
  try {
    const messages = [];
    
    // Busca elementos de mensagem do LinkedIn
    const messageElements = document.querySelectorAll('.msg-s-message-list__event');
    
    console.log(`Found ${messageElements.length} message elements`);
    
    // Extrai informações de cada mensagem
    messageElements.forEach((element, index) => {
      // Pega a data da conversa (se existir neste elemento)
      const dateHeading = element.querySelector('.msg-s-message-list__time-heading');
      const conversationDate = dateHeading?.textContent?.trim() || null;
      
      // Pega o container da mensagem
      const eventItem = element.querySelector('.msg-s-event-listitem');
      if (!eventItem) return;
      
      // Extrai timestamp da URN se disponível
      const urnAttr = eventItem.getAttribute('data-event-urn');
      let messageTimestamp = null;
      if (urnAttr) {
        // URN format: urn:li:msg_message:(...,2-MTc2NDA4MDI1ODU3N2IzNzE2Ny0xMDA...)
        // O número após '2-' é geralmente um timestamp em base64/hex
        const match = urnAttr.match(/2-([A-Za-z0-9]+)/);
        if (match) {
          try {
            // Tenta decodificar como timestamp Unix
            const decoded = atob(match[1]); // Base64 decode
            const timestampMatch = decoded.match(/\d{13,}/); // Busca timestamp em milisegundos
            if (timestampMatch) {
              messageTimestamp = new Date(parseInt(timestampMatch[0]));
            }
          } catch (e) {
            // Se falhar, ignora
          }
        }
      }
      
      // Extrai texto da mensagem
      const textEl = eventItem.querySelector('.msg-s-event-listitem__body');
      const text = textEl?.textContent?.trim() || '';
      
      // Extrai remetente
      const senderEl = eventItem.querySelector('.msg-s-message-group__name');
      const sender = senderEl?.textContent?.trim() || 'Unknown';
      
      // Extrai timestamp (horário)
      const timeEl = eventItem.querySelector('.msg-s-message-group__timestamp');
      const time = timeEl?.textContent?.trim() || '';
      
      if (text && text.length > 0) {
        messages.push({
          index: index + 1,
          sender: sender,
          text: text,
          time: time,
          conversationDate: conversationDate,
          absoluteDate: messageTimestamp ? messageTimestamp.toISOString() : null,
          dateDisplay: messageTimestamp ? messageTimestamp.toLocaleString() : null
        });
      }
    });

    const scrapedData = {
      success: true,
      totalMessages: messages.length,
      messages: messages,
      url: window.location.href,
      timestamp: new Date().toISOString(),
      pageTitle: document.title
    };

    console.log('Scraped data:', scrapedData);

    // POST to Rails backend
    const response = await fetch('http://localhost:3000/deals/find_or_create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(scrapedData)
    });

    const apiResponse = await response.json();

    return {
      scrapeData: scrapedData,
      apiResponse: apiResponse,
      success: true
    };
  } catch (error) {
    console.error('Scrape error:', error);
    return {
      success: false,
      error: error.message,
      stack: error.stack
    };
  }
})();

