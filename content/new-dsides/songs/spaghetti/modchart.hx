import funkin.data.Chart;

typedef Anim = {
	var time:Float;
	var data:Int;
	var length:Int;
}

var anims:Array<Anim> = [];

function onCreatePost()
{
    crowdChart = Chart.fromPath(Paths.json('spaghetti/data/extra'));
    if (crowdChart != null) {
        for (section in crowdChart.notes) {
            for (note in section.sectionNotes) {
                anims.push({
                    time: note[0],
                    data: Math.floor(note[1] % 4),
                    length: note[2]
                });
            }
        }
    }

    if(ClientPrefs.modcharts)
        loadModchart();
}

function onUpdate(elapsed)
{
    if(crowdChart != null)
    {
        for (anim in anims) {
            if (anim.time <= Conductor.songPosition) {
                var animToPlay:String = ['singLEFT-alt', 'singDOWN-alt', 'singUP-alt', 'singRIGHT-alt'][anim.data];
                gf.holdTimer = 0;
                gf.playAnim(animToPlay, true);
                var holdingTime = Conductor.songPosition - anim.time;
                if (anim.length == 0 || anim.length < holdingTime)
                    anims.remove(anim);
            }
        }
    }
}

function loadModchart()
{
    modManager.queueEase(544, 586, "beat", 0.5);
    modManager.queueSet(656, "beat", 0);
    modManager.queueSet(672, "beat", 0.5);
    modManager.queueEase(790, 798, "beat", 0);

    modManager.queueEase(604, 605, "localrotateZ", tr(-22), 'quadOut');
    modManager.queueEase(606, 607, "localrotateZ", tr(22), 'quadOut');

    modManager.queueEase(608, 612, "localrotateZ", 0, 'quadOut');

    var counter = -1;
    numericForInterval(672, 790, 8, (step)->{
        counter *= -1;
        modManager.queueSet(step, "mini", -0.5);
        modManager.queueEase(step, step + 4, "mini", 0, "quintOut");
        modManager.queueSet(step, "drunk", -2 * counter);
        modManager.queueEase(step, step + 4, "drunk", 0, "quintOut");

        modManager.queueSet(step + 4, "mini", -0.5);
        modManager.queueEase(step + 4, step + 8, "mini", 0, "quintOut");
        modManager.queueSet(step + 4, "tipsy", 2 * counter);
        modManager.queueEase(step + 4, step + 8, "tipsy", 0, "quintOut");
        modManager.queueSet(step + 4, "drunk", 2 * counter);
        modManager.queueEase(step + 4, step + 8, "drunk", 0, "quintOut");
    });

    // spinning stuff
    for(s in [672, 736]){
        modManager.queueSet(s, "localrotateY", tr(360 * 2));
        modManager.queueEase(s, s+6, "localrotateY", 0, 'quintOut');
    }

}

function tr(d){ return d * (3.14159265359 / 180); }

function numericForInterval(start, end, interval, func){
    var index = start;
    while(index < end){
        func(index);
        index += interval;
    }
}