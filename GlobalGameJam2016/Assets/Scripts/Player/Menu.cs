using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour {

	[SerializeField] protected Image topImage,
									 bottomImage;

	Image currentImage;

	void Awake(){
		currentImage = topImage;
		bottomImage.enabled = false;
	}

	void Update () {
		if (Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.DownArrow)){
			currentImage.enabled = false;
			if (currentImage == topImage){
				currentImage = bottomImage;
			}
			else{
				currentImage = topImage;
			}

			currentImage.enabled = true;
		}

		if (Input.GetKeyDown(KeyCode.Space)){
			if (currentImage == topImage){
				SceneManager.LoadScene("CronMaze");
			}
			else {
				SceneManager.LoadScene("RobPuzzle1");
			}
		}
	}
}
