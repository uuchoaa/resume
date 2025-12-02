/**
 * W2 Control Panel UI Logic
 */

// State
let currentState = {
  url: '',
  source: null as any,
  scenario: null as any,
  records: [] as any[],
  processors: [] as any[]
};

let selectedRecordId: string | null = null;
let pendingWriter: any = null;

// DOM Elements
const currentUrlEl = document.getElementById('current-url')!;
const currentSourceEl = document.getElementById('current-source')!;
const currentScenarioEl = document.getElementById('current-scenario')!;
const readersListEl = document.getElementById('readers-list')!;
const writersListEl = document.getElementById('writers-list')!;
const historyListEl = document.getElementById('history-list')!;
const clearHistoryBtn = document.getElementById('clear-history-btn')!;

// Navigation elements
const backBtn = document.getElementById('back-btn')!;
const forwardBtn = document.getElementById('forward-btn')!;
const reloadBtn = document.getElementById('reload-btn')!;
const urlInput = document.getElementById('url-input') as HTMLInputElement;
const goBtn = document.getElementById('go-btn')!;

// Writer Modal
const writerModal = document.getElementById('writer-modal')!;
const writerModalTitle = document.getElementById('writer-modal-title')!;
const writerInput = document.getElementById('writer-input') as HTMLTextAreaElement;
const writerCancelBtn = document.getElementById('writer-cancel-btn')!;
const writerSubmitBtn = document.getElementById('writer-submit-btn')!;

// Detail Modal
const detailModal = document.getElementById('detail-modal')!;
const detailModalTitle = document.getElementById('detail-modal-title')!;
const detailContent = document.getElementById('detail-content')!;
const detailCloseBtn = document.getElementById('detail-close-btn')!;
const processorSelect = document.getElementById('processor-select') as HTMLSelectElement;
const applyProcessorBtn = document.getElementById('apply-processor-btn')!;

// Initialize
(window as any).electronAPI.onInitData((data: any) => {
  console.log('Init data received:', data);
  currentState.processors = data.processors || [];
  updateProcessorSelect();
});

(window as any).electronAPI.onUrlChanged((data: any) => {
  console.log('URL changed:', data);
  currentState.url = data.url;
  currentState.source = data.source;
  currentState.scenario = data.scenario;
  updateUI();
});

(window as any).electronAPI.onDataUpdated((records: any[]) => {
  console.log('Data updated:', records);
  currentState.records = records;
  updateHistory();
});

function updateUI() {
  // Update URL
  currentUrlEl.textContent = currentState.url || '-';
  urlInput.value = currentState.url || '';
  
  // Update source
  currentSourceEl.textContent = currentState.source?.name || '-';
  
  // Update scenario
  currentScenarioEl.textContent = currentState.scenario?.name || '-';
  
  // Update readers
  if (currentState.scenario?.readers && currentState.scenario.readers.length > 0) {
    readersListEl.innerHTML = currentState.scenario.readers.map((reader: any) => `
      <button 
        class="w-full text-left px-3 py-2 bg-blue-50 hover:bg-blue-100 border border-blue-200 rounded text-sm"
        onclick="executeReader('${reader.id}')"
      >
        <div class="font-medium">${reader.name}</div>
        <div class="text-xs text-gray-600">${reader.description}</div>
      </button>
    `).join('');
  } else {
    readersListEl.innerHTML = '<p class="text-sm text-gray-500">No readers available for current page</p>';
  }
  
  // Update writers
  if (currentState.scenario?.writers && currentState.scenario.writers.length > 0) {
    writersListEl.innerHTML = currentState.scenario.writers.map((writer: any) => `
      <button 
        class="w-full text-left px-3 py-2 bg-green-50 hover:bg-green-100 border border-green-200 rounded text-sm"
        onclick="promptWriter('${writer.id}', '${writer.name}')"
      >
        <div class="font-medium">${writer.name}</div>
        <div class="text-xs text-gray-600">${writer.description}</div>
      </button>
    `).join('');
  } else {
    writersListEl.innerHTML = '<p class="text-sm text-gray-500">No writers available for current page</p>';
  }
}

function updateHistory() {
  if (currentState.records.length === 0) {
    historyListEl.innerHTML = '<p class="text-sm text-gray-500">No data extracted yet</p>';
    return;
  }

  historyListEl.innerHTML = currentState.records.map(record => {
    const result = record.result;
    const statusColor = result.success ? 'green' : 'red';
    const time = new Date(result.timestamp).toLocaleTimeString();
    
    return `
      <div class="border border-gray-200 rounded p-3 hover:bg-gray-50 cursor-pointer" onclick="showDetails('${record.id}')">
        <div class="flex justify-between items-start">
          <div class="flex-1">
            <div class="font-medium text-sm">${result.actionName}</div>
            <div class="text-xs text-gray-600">${result.sourceId} → ${result.scenarioId}</div>
            ${record.processed ? `<div class="text-xs text-purple-600 mt-1">✓ Processed by ${record.processed.processorName}</div>` : ''}
          </div>
          <div class="text-right">
            <span class="inline-block px-2 py-1 text-xs rounded bg-${statusColor}-100 text-${statusColor}-700">
              ${result.success ? 'Success' : 'Failed'}
            </span>
            <div class="text-xs text-gray-500 mt-1">${time}</div>
          </div>
        </div>
      </div>
    `;
  }).join('');
}

function updateProcessorSelect() {
  processorSelect.innerHTML = '<option value="">Select a processor...</option>' +
    currentState.processors.map(p => 
      `<option value="${p.id}">${p.name} - ${p.description}</option>`
    ).join('');
}

// Actions
(window as any).executeReader = async (readerId: string) => {
  if (!currentState.source || !currentState.scenario) return;
  
  console.log('Executing reader:', readerId);
  const result = await (window as any).electronAPI.executeReader(
    currentState.source.id,
    currentState.scenario.id,
    readerId
  );
  console.log('Reader result:', result);
};

(window as any).promptWriter = (writerId: string, writerName: string) => {
  pendingWriter = { writerId, writerName };
  writerModalTitle.textContent = writerName;
  writerInput.value = '';
  writerModal.classList.remove('hidden');
  writerInput.focus();
};

writerCancelBtn.addEventListener('click', () => {
  writerModal.classList.add('hidden');
  pendingWriter = null;
});

writerSubmitBtn.addEventListener('click', async () => {
  if (!pendingWriter || !currentState.source || !currentState.scenario) return;
  
  const inputData = writerInput.value.trim();
  writerModal.classList.add('hidden');
  
  console.log('Executing writer:', pendingWriter.writerId, 'with input:', inputData);
  const result = await (window as any).electronAPI.executeWriter(
    currentState.source.id,
    currentState.scenario.id,
    pendingWriter.writerId,
    inputData
  );
  console.log('Writer result:', result);
  
  pendingWriter = null;
});

(window as any).showDetails = (recordId: string) => {
  selectedRecordId = recordId;
  const record = currentState.records.find(r => r.id === recordId);
  if (!record) return;
  
  detailModalTitle.textContent = record.result.actionName;
  
  let content = {
    result: record.result,
    processed: record.processed
  };
  
  detailContent.textContent = JSON.stringify(content, null, 2);
  detailModal.classList.remove('hidden');
};

detailCloseBtn.addEventListener('click', () => {
  detailModal.classList.add('hidden');
  selectedRecordId = null;
});

applyProcessorBtn.addEventListener('click', async () => {
  if (!selectedRecordId || !processorSelect.value) return;
  
  console.log('Applying processor:', processorSelect.value, 'to record:', selectedRecordId);
  const result = await (window as any).electronAPI.executeProcessor(selectedRecordId, processorSelect.value);
  console.log('Processor result:', result);
  
  // Refresh details
  if (result.success) {
    const record = currentState.records.find(r => r.id === selectedRecordId);
    if (record) {
      detailContent.textContent = JSON.stringify({
        result: record.result,
        processed: record.processed
      }, null, 2);
    }
  }
});

clearHistoryBtn.addEventListener('click', async () => {
  if (confirm('Clear all data history?')) {
    await (window as any).electronAPI.clearRecords();
  }
});

// Navigation controls
backBtn.addEventListener('click', async () => {
  await (window as any).electronAPI.navigateBack();
});

forwardBtn.addEventListener('click', async () => {
  await (window as any).electronAPI.navigateForward();
});

reloadBtn.addEventListener('click', async () => {
  await (window as any).electronAPI.reload();
});

goBtn.addEventListener('click', async () => {
  const url = urlInput.value.trim();
  if (url) {
    await (window as any).electronAPI.navigateTo(url);
  }
});

urlInput.addEventListener('keypress', async (e) => {
  if (e.key === 'Enter') {
    const url = urlInput.value.trim();
    if (url) {
      await (window as any).electronAPI.navigateTo(url);
    }
  }
});

// Close modals on Escape
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    writerModal.classList.add('hidden');
    detailModal.classList.add('hidden');
  }
});

