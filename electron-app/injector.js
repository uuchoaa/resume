// Script injetado em W1 para injetar texto no textarea do LinkedIn
// Este script roda no contexto da página (W1)

(function(responseText) {
  console.log('💬 Injecting response:', responseText);
  
  try {
    // Seletores possíveis para o textarea do LinkedIn
    const selectors = [
      '.msg-form__contenteditable',           // Textarea principal
      '[data-placeholder="Write a message..."]',
      '.msg-form__msg-content-container--scrollable',
      '[contenteditable="true"]',             // Genérico
      'div[role="textbox"]'                   // ARIA role
    ];
    
    let textarea = null;
    
    // Tenta encontrar o textarea
    for (const selector of selectors) {
      const element = document.querySelector(selector);
      if (element) {
        textarea = element;
        console.log('✅ Found textarea using selector:', selector);
        break;
      }
    }
    
    if (!textarea) {
      console.error('❌ Textarea not found');
      return {
        success: false,
        error: 'LinkedIn message textarea not found'
      };
    }
    
    // Injeta o texto
    // Para contenteditable divs (como LinkedIn usa)
    if (textarea.getAttribute('contenteditable') === 'true') {
      // Limpa conteúdo atual
      textarea.innerHTML = '';
      
      // Adiciona texto como parágrafo
      const p = document.createElement('p');
      p.textContent = responseText;
      textarea.appendChild(p);
      
      // Trigger eventos para notificar React/Vue
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      textarea.dispatchEvent(new Event('change', { bubbles: true }));
      
      // Focus no textarea
      textarea.focus();
      
      // Move cursor para o fim
      const range = document.createRange();
      const sel = window.getSelection();
      range.selectNodeContents(textarea);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
      
    } else {
      // Fallback para textarea normal
      textarea.value = responseText;
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      textarea.dispatchEvent(new Event('change', { bubbles: true }));
      textarea.focus();
    }
    
    console.log('✅ Text injected successfully!');
    return {
      success: true,
      message: 'Response injected successfully'
    };
    
  } catch (error) {
    console.error('❌ Injection error:', error);
    return {
      success: false,
      error: error.message
    };
  }
});

