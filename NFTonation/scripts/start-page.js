// ---- METAMASK ELEMENTS ----
const connectButton = document.getElementById("connect-button");
const walletID = document.getElementById("wallet-id");
const reloadButton = document.getElementById("reload-button");
const installAlert = document.getElementById("install-alert");
// ---- OTHER ELEMENTS ----
const startPage = document.getElementsByClassName("start-page");
const votePage = document.getElementsByClassName("vote-page");
const votingPageButton = document.getElementById("vote-page-button");
const connectedWallet = document.getElementById("wallet-display");

export let walletId = ``;

connectButton.addEventListener("click", () => {
    if (typeof window.ethereum !== "undefined") {
        ethereum
            .request({ method: "eth_requestAccounts" })
            .then((accounts) => {
                const account = accounts[0]
                walletId = `<p>${account}</p>`;
                walletID.innerHTML = `<span>Wallet connected: ${account}</span>`;
                votingPageButton.disabled = false
            }).catch((error) => {
            console.log(error, error.code);
        });
    } else {
        window.open("https://metamask.io/download/", "_blank");
        installAlert.classList.add("show");
    }
})

reloadButton.addEventListener("click", () => {
    window.location.reload();
});

votingPageButton.addEventListener("click", () => {
    startPage[0].style.display = "none";
    votePage[0].style.display = "flex";
    connectedWallet.innerHTML = walletId;
})