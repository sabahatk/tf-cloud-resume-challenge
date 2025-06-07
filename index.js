const getApiURL = "https://api.sabahatresume.com/retrieve"
const updApiURL = "https://api.sabahatresume.com/update"

async function counter_update(){
    var counter = document.getElementById("counter");
    var count = 0;

    try{
        fetch(updApiURL);

        const response = await fetch(`${getApiURL}?timestamp=${new Date().getTime()}`);
        if(!response.ok){
            throw new Error("Network response error when fetching DynamoDB API")
        }
        
        const data = await response.json();
        console.log("Item data: ", data);
        count = data.body;
    }
    catch(error){
        console.error("Error fetching count data");
    }
    counter.innerHTML = count;
}
window.onload = counter_update;