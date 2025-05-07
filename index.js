
const getApiURL = "https://hfdp9i9upb.execute-api.us-east-1.amazonaws.com/Test/getCounterItem"

async function counter_update(){
    var counter = document.getElementById("counter");
    var count = 0;

    try{
        //const call_api = await fetch("https://c1b950zpkg.execute-api.us-east-1.amazonaws.com/default/visitor-counter");
        fetch("https://c1b950zpkg.execute-api.us-east-1.amazonaws.com/default/visitor-counter");
        //if(!call_api.ok){
            //throw new Error("Network response error when calling Lambda API")
        //}

        const response = await fetch(`${getApiURL}?timestamp=${new Date().getTime()}`);
        if(!response.ok){
            throw new Error("Network response error when fetching DynamoDB API")
        }
        
        //const data = response.json();
        const data = await response.json();
        console.log("Item data: ", data);
        count = data.body;
        
        /*count = response.json();
        console.log(count);
        counter.innerHTML = count;*/
    }
    catch(error){
        console.error("Error fetching count data");
    }
    counter.innerHTML = count;
}
window.onload = counter_update;