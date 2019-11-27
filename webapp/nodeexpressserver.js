var express        =         require("express");
var bodyParser     =         require("body-parser");
var app            =         express();

//app.use(bodyParser.urlencoded({ extended: false }));
var urlencodedParser = bodyParser.urlencoded({ extended: false })
//app.use(bodyParser.json({ type: 'application/*+json' }))
var jsonParser = bodyParser.json();

app.get('/',function(req,res){
    var obj = {
        firstname : 'sample',
        lastname : 'response'
    };
    res.writeHead(200,
	{"Content-Type" : "application/json"});
	res.end(JSON.stringify(obj));
});

app.post('/builds',jsonParser, function(req,res){
   builds = req.body.jobs.Build_base_AMI.Builds;      // your JSON
    // sort 
   sorted = builds.sort(compare);
   function compare(a, b) {
        const aTime = parseInt(a.build_date);
        const bTime = parseInt(b.build_date);
        let comparison = 0;
        if (aTime > bTime) {
            comparison = 1;
        } else if (aTime < bTime) {
            comparison = -1;
        }
        return comparison;
    }
    
    value = sorted[0]
    var tokenized = value.output.split(" "); 
    var data = {
        latest :{ 
            build_date: "",
            ami_id:  "", 
            commit_hash: "" 
        }
    };
    if (tokenized.length > 0) {
        // console.log("output does not contain ami id and hash , will print out empty string for commit_hash");
        data = {
            latest :{ 
                build_date: value.build_date,
                ami_id: (tokenized.length < 2 ?  "": tokenized[2] ), 
                commit_hash: (tokenized.length < 3 ?  "": tokenized[3] ) 
            }
        };
    } 
    
   res.send(data); 
});
app.listen(8000,function(){
  console.log("Started on PORT 8000");
})



