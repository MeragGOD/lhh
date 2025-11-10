'use strict';

let vmIndex = 0;

document.addEventListener("DOMContentLoaded", () => {
    addOneVm(); // Thêm 1 VM mặc định
    document.getElementById("btnAddVm").addEventListener("click", addOneVm);
    updateSubmitState(); // Enable/disable submit dựa trên VM count
});

function addOneVm() {
    const container = document.getElementById("vmsStart");
    if (!container) return;

    const card = document.createElement("div");
    card.className = "card";
    card.id = `vm${vmIndex}`;
    card.innerHTML = `
        <h3><i class="fas fa-laptop"></i> VM #${vmIndex + 1}</h3>
        <input type="text" name="vm[${vmIndex}][name]" placeholder="VM Name (e.g., my-vm-01)" required maxlength="63">
        <select name="vm[${vmIndex}][cloud_type]" required>
            <option value="">Select Cloud Type</option>
            <option value="AWS">AWS</option>
            <option value="GCP">GCP</option>
            <option value="Azure">Azure</option>
        </select>
        <input type="number" name="vm[${vmIndex}][cpu]" placeholder="CPU Cores (e.g., 2)" min="1" required>
        <input type="number" name="vm[${vmIndex}][memory]" placeholder="Memory (MB, e.g., 2048)" min="512" required>
        <input type="number" name="vm[${vmIndex}][storage]" placeholder="Storage (GB, e.g., 50)" min="10" required>
        <input type="text" name="vm[${vmIndex}][ip]" placeholder="IP Address (optional)">
        <button type="button" class="remove-vm" onclick="deleteVm(${vmIndex})">
            <i class="fas fa-trash"></i> Delete
        </button>
    `;
    container.appendChild(card);
    vmIndex++;
    document.getElementById("newVmNum").value = vmIndex;
    updateSubmitState();
}

function deleteVm(indexToDelete) {
    const card = document.getElementById(`vm${indexToDelete}`);
    if (!card) return;

    card.remove();
    vmIndex--;
    document.getElementById("newVmNum").value = vmIndex;
    renumberVms(); // Renumber index và names
    updateSubmitState();
}

function renumberVms() {
    const cards = document.querySelectorAll("#vmsStart .card");
    let newIndex = 0;
    cards.forEach((card) => {
        // Update title
        card.querySelector("h3").innerHTML = `<i class="fas fa-laptop"></i> VM #${newIndex + 1}`;
        
        // Update names của tất cả inputs/select
        const inputs = card.querySelectorAll('input, select');
        inputs.forEach((input) => {
            const oldName = input.name;
            if (oldName) {
                const newName = oldName.replace(/vm\[\d+\]/, `vm[${newIndex}]`);
                input.name = newName;
            }
        });
        
        // Update id và onclick delete
        card.id = `vm${newIndex}`;
        const deleteBtn = card.querySelector('.remove-vm');
        if (deleteBtn) {
            deleteBtn.setAttribute('onclick', `deleteVm(${newIndex})`);
        }
        
        newIndex++;
    });
    vmIndex = newIndex; // Update global count
}

function updateSubmitState() {
    const submitBtn = document.getElementById("vmsInfoSubmit");
    const hasVms = document.querySelectorAll("#vmsStart .card").length > 0;
    submitBtn.disabled = !hasVms;
}

function whileAddingVms() {
    const submitButton = document.getElementById("vmsInfoSubmit");
    submitButton.disabled = true;
    const msg = document.createElement("p");
    msg.innerText = "Creating Virtual Machines, please wait ...";
    msg.style.color = "#58a6ff"; // Màu xanh cho pro
    submitButton.insertAdjacentElement('afterend', msg);
}

// Validation trước submit (gọi từ onsubmit của form trong template)
function validateAndSubmit() {
    let isValid = true;
    const nameInputs = document.querySelectorAll('input[name$="[name]"]');
    nameInputs.forEach((input) => {
        const name = input.value.trim();
        if (!name) {
            isValid = false;
            return;
        }
        // Regex DNS label (RFC 1123: lowercase alphanum + '-', start/end alphanum, max 63)
        const dnsRegex = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/;
        if (!dnsRegex.test(name) || name.length > 63) {
            alert(`Invalid VM name "${name}": Must be lowercase alphanumeric + '-', start/end with alphanumeric, max 63 chars.`);
            input.focus();
            isValid = false;
            return;
        }
    });
    
    // Check required fields khác (nếu cần)
    const requiredInputs = document.querySelectorAll('input[required], select[required]');
    for (let input of requiredInputs) {
        if (!input.value.trim()) {
            alert('Please fill all required fields!');
            input.focus();
            isValid = false;
            break;
        }
    }
    
    if (!isValid) {
        event.preventDefault(); // Ngăn submit nếu lỗi
    } else {
        whileAddingVms(); // Chạy loading nếu valid
    }
    return isValid;
}