class EasterEgg extends GGKactor
	placeable;

var bool mIsBlue;
var bool mIsYellow;
var bool mIsRed;

function InitEgg()
{
	if(MaterialInstanceConstant(StaticMeshComponent.GetMaterial(0)) == none)
	{
		StaticMeshComponent.CreateAndSetMaterialInstanceConstant( 0 );
	}

	UpdateColor();

	SetMassScale( 1000000.f );
	StaticMeshComponent.WakeRigidBody();
}

function UpdateColor()
{
	local MaterialInstanceConstant mic;
	local color randColor;
	local LinearColor newColor;

	mic=MaterialInstanceConstant(StaticMeshComponent.GetMaterial(0));

	randColor = MakeColor(Rand(256), Rand(256), Rand(256), 255);

	newColor = ColorToLinearColor( randColor );
	mic.SetVectorParameterValue( 'color', newColor );
}

function int GetScore()
{
	return 1;
}

/**
 * Access to the in game name of this actor
 */
function string GetActorName()
{
	return "Easter Egg";
}

DefaultProperties
{
	Begin Object name=StaticMeshComponent0
		StaticMesh=StaticMesh'Space_Particles.Meshes.Egg'
		Materials(0)=Material'Zombie_Particles.Materials.Confetti_Mat'
		Scale3D=(X=0.2f,Y=0.2f,Z=0.2f)
	End Object

	bNoDelete=false
	bStatic=false
}