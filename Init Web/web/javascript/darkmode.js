let darkModeBtn = document.getElementById('darkmode-btn');
let cssName = document.getElementById('main-css');

if (localStorage.getItem('darkmode') === 'true') {
    cssName.href = 'dark.css';
} else {
    cssName.href = 'tphtml.css';
}

function toggleDarkmode(){
    let currentHref = cssName.href;

    if(currentHref.includes("tphtml.css")) {
        cssName.href = 'dark.css';
        localStorage.setItem('darkmode', 'true');
    } else {
        cssName.href = 'tphtml.css';
        localStorage.setItem('darkmode', 'false');
    }
}

// Événement sur le bouton
darkModeBtn.addEventListener('click', toggleDarkmode);