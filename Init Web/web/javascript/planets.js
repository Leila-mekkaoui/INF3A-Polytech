function writeText(txt) {
    document.getElementById("desc").innerHTML = txt;
}

function writeDefault(){
    document.getElementById("desc").innerHTML = "Mouse over the sun and the planets and see the different descriptions.";
}


function imgPlanet(planet){
    if (planet == 'sun'){
        document.getElementById("planet").setAttribute("src", "images/sun.gif");
    }
    else if(planet=='mercury'){
        document.getElementById("planet").setAttribute("src", "images/merglobe.gif");
    }
    else{
        document.getElementById("planet").setAttribute("src", "images/venglobe.gif");
    }
}

function imgDefault(){
    document.getElementById("planet").setAttribute("src", "images/stars.jpg");
}