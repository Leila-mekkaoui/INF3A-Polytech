function TurnOnOffBulb()
{
    let ampoule = document.getElementById('bulb');
    let chemin = ampoule.src;

    if(chemin.search("off")===-1)
    {
        ampoule.src = 'images/pic_bulboff.gif';
    }
    else
    {
        ampoule.src = 'images/pic_bulbon.gif';
    }

}