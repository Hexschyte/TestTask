const modalElement = document.getElementById('add-modal');
const modal = new bootstrap.Modal(modalElement);
const modal_caption = document.getElementById("modal-caption")

const id_obj = document.getElementById("modal-id-txt");
const name_obj = document.getElementById("modal-name-txt");
const dsc_obj = document.getElementById("modal-dsc-txt");
const apply_btn = document.getElementById("modal-apply-btn");

const search_btn = document.getElementById("search-btn");
const reset_btn = document.getElementById("reset-btn");

const table = document.getElementById('product-table-container');

modalElement.addEventListener('hide.bs.modal', () => {
    name_obj.value = '';
    dsc_obj.value = '';
})

table.addEventListener('click', function (e) {

    const target = e.target;
    const prd = target.closest('tr');

    if (!prd) return;

    if (target.classList.contains('btn-delete')) {
        deleteProduct(prd.id);
    } else if (target.classList.contains('btn-edit')) {

        modal_caption.innerHTML = "Change Product"
        name_obj.value = prd.getElementsByClassName('product-name')[0].innerText

        modal.show();
        apply_btn.onclick = () => editProduct(prd.id);
    }
});

document.getElementById("create-btn").addEventListener('click', () => {
    modal_caption.innerHTML = "Add Product"
    modal.show();
    apply_btn.onclick = () => createProduct();
})

search_btn.addEventListener('click', (e) => {
    search(e)
})

reset_btn.addEventListener('click', () => {
    reloadTable()
})

async function sendRequest(url, method, body = null) {
    let options = {
        method: method,
        headers: {
            'Content-Type': 'application/json;charset=utf-8'
        }
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    try {
        const response = await fetch(url, options);

        if (!response.ok) {
            const errorMessage = await response.text();
            document.getElementById("modal-error-msg").textContent = errorMessage;
            throw new Error(`Error ${response.status}: ${errorMessage}`);
        }

        await reloadTable();
        modal.hide();

    } catch (error) {
        console.error('Unknown error: ', error);
    }
}

// Удаление продукта
function deleteProduct(productId) {
    sendRequest('/api/product/' + productId, 'DELETE');
}

// Добавление продукта
function createProduct() {

    let cnew = {
        Name: name_obj.value,
        Description: dsc_obj.value
    };

    sendRequest('/api/product/', 'POST', cnew);
}

// Редактирование продукта
function editProduct(productId) {

    let cnew = {
        Id: productId,
        Name: name_obj.value,
        Description: dsc_obj.value
    };

    sendRequest('/api/product/', 'PUT', cnew);
}

function search() {
    let t = document.getElementById('search-input').value

    fetch(`/Product/FilterProducts?searchString=${encodeURIComponent(t)}`)
        .then(response => response.text())
        .then(html => {
            document.getElementById('product-table-container').innerHTML = html;
        });
}

async function reloadTable() {
    try {
        const response = await fetch(`/Product/FilterProducts`);
        if (!response.ok) {
            throw new Error(`Error ${response.status}: ${response.statusText}`);
        }

        const html = await response.text();
        document.getElementById('product-table-container').innerHTML = html;
    } catch (error) {
        console.error('Error in reloadTable:', error);
    }
}


