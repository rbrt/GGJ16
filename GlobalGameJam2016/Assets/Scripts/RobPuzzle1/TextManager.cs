using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class TextManager : MonoBehaviour {

	static TextManager instance;

	public static TextManager Instance {
		get {
			return instance;
		}
	}

	[SerializeField] Text targetText;

	static string introString = "COMPLETE THE RITUALS",
				  successString = "RITUAL COMPLETED",
				  ultimateSuccessString = "TRANSCENDED THE MORTAL PLANE",
				  failureString = "RITUAL FAILED";

	bool showingText = false;

	void Awake(){
		if (instance == null){
			instance = this;
		}
	}

	void Start () {
		this.StartSafeCoroutine(ShowText(introString, delay: 1));
	}

	public void ShowSuccessString(){
		this.StartSafeCoroutine(ShowText(successString));
	}

	public void ShowUltimateSuccessString(){
		this.StartSafeCoroutine(ShowText(ultimateSuccessString));
	}

	public void ShowFailureString(){
		this.StartSafeCoroutine(ShowText(failureString));
	}

	IEnumerator ShowText(string text, int delay = 0){
		yield return new WaitForSeconds(delay);
		while (showingText){
			yield return null;
		}

		showingText = true;
		var color = targetText.color;
		targetText.text = text;
		for (float i = 0; i < 1; i += Time.deltaTime){
			color.a = i;
			targetText.color = color;
			yield return null;
		}

		yield return new WaitForSeconds(2);

		for (float i = 0; i < 1; i += Time.deltaTime){
			color.a = 1 - i;
			targetText.color = color;
			yield return null;
		}
		color.a = 0;
		targetText.color = color;
		targetText.text = "";

		showingText = false;
	}
}
