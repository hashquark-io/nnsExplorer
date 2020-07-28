import * as $ from "jquery";
import "bootstrap";

// Make the nnsexplorer app's public methods available locally
import nnsexplorer from "ic:canisters/nnsexplorer";
import assets from "ic:canisters/nnsexp_assets";

import "bootstrap/dist/css/bootstrap.min.css";
import "animate.css/animate.min.css";
import "./index.css";

window.$ = window.jQuery = $;

assets
    .retrieve("index.html")
    .then(function(array) {
        let buffer = new Uint8Array(array);
        const html = new TextDecoder().decode(buffer);
        const el = new DOMParser().parseFromString(html, "text/html");
        document.body.replaceChild(el.firstElementChild, document.getElementById('app'));
    })
    .then(() =>
        $(document).ready(function() {
            // Show list of validators
            (async function() {
                try {
                    const jsonKey = ["Account Address", "Total Neurons", "Description", "Commission Rate"];
                    const results = await nnsexplorer.showList();
                    var jsonElements = $.parseJSON(results);
                    var validatorList = document.getElementById("neuronHolderList");
                    var i = 1;
                    jsonElements.forEach(element => {
                        var row = validatorList.insertRow();
                        var num = row.insertCell();
                        num.innerHTML = i;

                        jsonKey.forEach(key => {
                            var cell = row.insertCell();
                            if (key === "Commission Rate") {
                                cell.innerHTML = element[key] + "%";
                            } else if (key === "Total Neurons") {
                                cell.innerHTML = "random value"
                            } else {
                                cell.innerHTML = element[key];
                            }
                        })

                        var performance = row.insertCell();
                        performance.innerHTML = "100%";

                        var btnDele = row.insertCell();
                        btnDele.innerHTML = '<button type="button" id="delegateBtn" class="btn" onclick="changeImage()">Delegate</button>';

                        i++;
                    })
                } catch (err) {
                    console.error(err);
                }
            })();

            $("#stakeAndVoteBtn").click(function() {
                $("#stakeAndVoteModal").modal("show");
            })

            // // Delegating function
            // $("#delegateBtn").click(function() {
            //     alert("delegated!");
            // });

            // Register for a neutron holder
            $("#stakeAndVoteForm").submit(async function(event) {
                event.preventDefault();

                const accountAddr = $(this).find("#regAccountAddr").val();
                const description = $(this).find("#regDescription").val();
                const commissionRate = $(this).find("#regCommissionR").val();

                async function action() {
                    await nnsexplorer.createProfile({
                        accountAddr,
                        description,
                        commissionRate,
                    });
                }
                await action();

                $('#stakeAndVoteModal').modal("hide");
                location.reload();
            });
        })
    );