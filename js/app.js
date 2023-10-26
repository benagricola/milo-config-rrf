var files = {};
const TYPE_BOARD    = 0;
const TYPE_GCODE    = 1;
const TYPE_TEMPLATE = 2;

const NET_MODE_CLIENT = "wifi_client";
const NET_MODE_AP = "wifi_ap";

const DRIVER_TYPE_TMC5160 = "tmc5160";
const DRIVER_TYPE_TMC2209 = "tmc2209";

// Implement next and back buttons
$('button[name="next-tab"]').on('click', (e) => {
    e.preventDefault();

    // Check visible form fields when clicking next.
    var valid = true;
    $('input:visible').each((_, e) => {
        if (!e.reportValidity()) {
            valid = false;
        }
    });

    if (!valid) {
        return true;
    }

    var nextTabId = e.target.closest('div.tab-pane').nextElementSibling.id;
    $(`#nav li button[id="${nextTabId}-tab"]`).tab('show');
});

$('button[name="last-tab"]').on('click', (e) => {
    e.preventDefault();
    var lastTabId = e.target.closest('div.tab-pane').previousElementSibling.id;
    $(`#nav li button[id="${lastTabId}-tab"]`).tab('show');
});

$("#nav li button[id='generated-config-tab']").on('show.bs.tab', (e) => {
    var formValues = {};
    $('form').serializeArray().forEach((a) => {
        var val = a.value != "" ? a.value : $(`form input[name="${a.name}"]`).prop('placeholder');
        if (a.name in formValues) {
            if (formValues[a.name].push) {
                formValues[a.name].push(val);
            } else {
                // Create array using existing scalar value
                formValues[a.name] = [formValues[a.name], val];
            }
        } else {
            formValues[a.name] = val;
        }
    });
    renderTemplates(formValues);
    generateZip(formValues['mcu_type']);
});

// Process finish button and enable generated config
$('button[name="submit"]').on('click', (e) => {
    if (!$('form')[0].reportValidity()) {
        return true;
    }
    $("#nav li button[id='generated-config-tab']").removeClass('disabled').tab('show');
    return false;
});

// Disable low voltage drivers when 48v selected
$('input[name="motor_voltage"]').on('change',() => {
    var disable = this.value == 48;

    // Disable 24v-only drivers
    $('select[name="driver_type"] option[data-24v-only]').prop('disabled', disable);

    // Select first driver capable of 48v when disabled
    if (disable) {
        $('select[name="driver_type"] option[data-24v-only!=""]').prop('selected', true);
    }
});

// Function stolen from https://codepen.io/gskinner/pen/BVEzox to allow indentation
// of config files within JS code without breaking output.
function dedent(str) {
    str = str.replace(/^\n/, "");
    let match = str.match(/^\s+/);
    return match ? str.replace(new RegExp("^" + match[0], "gm"), "") : str;
}

function renderTemplate(t, f, ft) {
    try {
        return eval("`" + t + "`");
    } catch(e) {
        console.log(`Error rendering template: ${e}`);
    }
}

function renderTemplates(f, board) {
    var ft = f['features'];

    for([src, file] of Object.entries(files)) {
        console.log(src, file);
        if((file['type'] === TYPE_BOARD && src == board) ||
            (file['type'] === TYPE_TEMPLATE)) {
            const tr = renderTemplate(file['input'], f, ft);
            file['input'] = tr;
        }
    }
};

async function generateZip(board) {
    console.log("Generating Zip file");

    const zip = new fflate.Zip();
    var zipData = [];

    // On each zip output chunk, push it into the zipData array
    // When final chunk, add object URL to download button.
    zip.ondata = (err, chunk, final) => {
        if (err) {
            console.log(err);
            return;
        }
        zipData.push(chunk);
        if(final) {
            const link = $('a#download-bundle')[0];
            link.href = URL.createObjectURL(new Blob(zipData, { type: 'application/zip' }));
            link.download = "milo-rrf-config.zip";
        }
    };

    // Push all necessary files into zip, do not compress as they're already downloaded.
    for([src, file] of Object.entries(files)) {
        if(file['type'] == TYPE_BOARD) {
            if(src != board) {
                continue;
            }
        }
        const zipFile = new fflate.ZipPassThrough(file['name'].slice(1));
        zip.add(zipFile);
        zipFile.push(file['input'], true);
    }

    zip.end();
}

$(async function () {
    try {

        const config = await loadJSONFile('config');

        // Neither of these are actually lists.
        const fileList     = Object.entries(await loadJSONFile('gcode-files'));
        const boardList    = Object.entries(await loadJSONFile('board-files'));
        const templateList = Object.entries(await loadJSONFile('template-files'));

        var fileRoot = `${config['downloadRoot']}/${config['downloadBranch']}`;

        // Pre-download the files as page is loading!
        const requests = [];
        for ([src, dst] of fileList) {
            var request = fetch(fileRoot + src);
            requests.push(request);
            files[src] = { name: dst, input: "", type: TYPE_GCODE, promise: request };
        }

        for ([boardName, info] of boardList) {
            var request = fetch(fileRoot + info['src']);
            requests.push(request);
            files[boardName] = { name: info['dst'], input: "", type: TYPE_BOARD, promise: request };
        }

        for ([templateName, dst] of templateList) {
            var request = fetch(fileRoot + info['src']);
            requests.push(request);
            files[templateName] = { name: dst, input: "", type: TYPE_TEMPLATE, promise: request };
        }

        const errors = (await Promise.all(requests)).filter((response) => !response.ok);

        if (errors.length > 0) {
            throw Error("Unable to download required files, please try again.");
        }

        for ([src, info] of Object.entries(files)) {
            info['input'] = await (await info['promise']).text();
            delete info['promise'];
            files[src] = info;
        }

    } catch (error) {
        console.log(error);
        $('#alert').text(`ERROR: ${error.toString()}`).show();
    }
});

async function loadJSONFile(fileName) {
    const response = await fetch(`./${fileName}.json`);
    if (!response.ok) {
        return {};
    }
    return response.json();
}