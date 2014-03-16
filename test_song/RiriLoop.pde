public class RiriLoop extends RiriObject {

	private RiriSequence sequence;
	private ArrayList<RiriObject> notes;

	/*
	* Default Constructor
	*/
	public RiriLoop() {
		sequence = new RiriSequence();
		notes = new ArrayList<RiriObject>();
		playing = false;
	}

	/*
	* Constructor
	* @param ArrayList<RiriObject> aNotes - notes to play in the loop
	*/
	public RiriLoop(ArrayList<RiriObject> aNotes) {
		sequence = new RiriSequence();
		notes = new ArrayList<RiriObject>(aNotes);
		playing = false;
	}

	/*
    * start() - Start executing the thread
    */
	public void start() {
		super.start();	
	}

	/*
    * run() - Thread execution function
    */
	public void run() {
		while (running && counter < repeats) {
			loopOn();
			duration = sequence.duration();
			try {
				sleep((long) duration);
			}
			catch (Exception e) {
				println("iunno...");
			}
			loopOff();
			if (!infinite) {
				counter++;
			}
		}
		println("done");
	}

	/*
    * quit() - Stop executing the thread
    */
	public void quit() {
		if (running) {
			super.quit();
		}
	}

	/*
	* loopOn() - Play the loop
	*/
	public void loopOn() {
		if (!playing) {
			println("looping");
			sequence = new RiriSequence();
			ArrayList<RiriObject> newNotes = new ArrayList<RiriObject>();
			for (int i = 0; i < notes.size(); i++) {
				newNotes.add(notes.get(i).clone());
			}
			sequence.notes(newNotes);
			sequence.start();
			playing = true;
		}
	}

	/*
	* loopOff() - Stop the loop
	*/
	public void loopOff() {
		if (playing) {
			//sequence.quit();
			playing = false;
		}
	}

	/*
	* addNote() - Add a note
	* @param RiriNote note - The RiriNote to add to the sequence
	*/
	public void addNote(RiriNote note) {
	    notes.add(note);
	}
	  
	/*
	* addNote() - Add a note
	* @param int channel - channel the note should play on
	* @param int pitch - pitch of the note
	* @param int velocity - velocity of the note 
	* @param int duration - duration of the note (in milliseconds)
	*/
	public void addNote(int channel, int pitch, int velocity, int duration) {
		notes.add(new RiriNote(channel, pitch, velocity, duration)); 
	}

	/*
	* addNote() - Add a note
	* @param int channel - channel the note should play on
	* @param int pitch - pitch of the note
	* @param int velocity - velocity of the note 
	* @param int duration - duration of the note (in milliseconds)
	* @param int repeats - number of times to repeat the note)
	*/
	public void addNote(int channel, int pitch, int velocity, int duration, int repeats) {
		notes.add(new RiriNote(channel, pitch, velocity, duration, repeats)); 
	}

	/*
	* addRest() - Add a note with no pitch/velocity
	* @param int channel - channel the note should play on
	* @param int duration - duration of the note (in milliseconds)
	*/
	public void addRest(int channel, int duration) {
		notes.add(new RiriNote(channel, 0, 0, duration)); 
	}

	/*
	* addChord() - Add a chord
	* @param RiriChord chord - The RiriChord to add to the sequence
	*/
	public void addChord(RiriChord chord) {
		notes.add(chord);
	}

	/*
	* clear() - Empty the sequence
	*/
	public void clear() {
		notes = new ArrayList<RiriObject>();
	}

	/*
    * clone() - Create a copy of the RiriLoop
    */
    public RiriObject clone() {
	    RiriLoop clone = new RiriLoop();
	    clone.duration(this.duration);
	    clone.repeats(this.repeats);
	    clone.infinite(this.infinite);
	    clone.notes = new ArrayList<RiriObject>();
	    for (int i = 0; i < this.notes.size(); i++) {
	        clone.notes.add(this.notes.get(i).clone());
	    }
	    return clone;
    }
}