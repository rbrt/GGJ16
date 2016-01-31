using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class Menu : MonoBehaviour {

	[SerializeField] protected Image topImage,
									 bottomImage;

	Image currentImage;

	void Awake(){
		currentImage = topImage;
		bottomImage.SetActive(false);
	}

	void Update () {
		if (Input.GetKeyDown(KeyCode.Up) || Input.GetKeyDown(KeyCode.Down)){
			currentImage.SetActive(false);
			if (currentImage == topImage){
				currentImage = bottomImage;
			}
			else{
				currentImage = topImage;
			}

			currentImage.SetActive(true);
		}
	}
}
