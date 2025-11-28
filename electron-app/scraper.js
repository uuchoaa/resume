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
      // Pega o container da mensagem
      const eventItem = element.querySelector('.msg-s-event-listitem');
      if (!eventItem) return;
      
      // Extrai texto da mensagem
      const textEl = eventItem.querySelector('.msg-s-event-listitem__body');
      const text = textEl?.textContent?.trim() || '';
      
      // Extrai remetente
      const senderEl = eventItem.querySelector('.msg-s-message-group__name');
      const sender = senderEl?.textContent?.trim() || 'Unknown';
      
      // Extrai timestamp
      const timeEl = eventItem.querySelector('.msg-s-message-group__timestamp');
      const timestamp = timeEl?.textContent?.trim() || '';
      
      if (text && text.length > 0) {
        messages.push({
          index: index + 1,
          sender: sender,
          text: text,
          timestamp: timestamp
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

