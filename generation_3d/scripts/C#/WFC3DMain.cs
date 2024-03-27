using Godot;
using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using ItemInfoClass;
using System.Linq;

public partial class WFC3DMain : Node
{
	const string CONSTRAINT_BOTTOM = "bot";
	const string CONSTRAINT_TOP = "top";

	const int pX = 0;
	const int pY = 1;
	const int nX = 2;
	const int nY = 3;
	const int pZ = 4;
	const int nZ = 5;


	[Export]
	string JsonPath;
	[Export]
	Vector3I Size = new Vector3I(8, 3, 8);

	[Export]
	int Seed = 0;
	[Export] 
	bool Update = false;
	GridMap GridMap;
	Label SeedLabel;
	Label SizeLabel;
	ProgressBar ProgressBar;

	Dictionary<string, ItemInfo> PrototypeData;
	WFC3DModel WFC = null;
	Vector3I Coords;

	public override void _Ready()
	{
		GridMap = GetNode<GridMap>("GridMap");
		SeedLabel = GetNode<Label>("Labels/SeedLabel");
		SizeLabel = GetNode<Label>("Labels/SizeLabel");
		ProgressBar = GetNode<ProgressBar>("ProgressBar");
		SeedLabel.Text = "Seed: " + Seed;
		LoadPrototypeData();
		Test();
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (Input.IsActionJustPressed("ui_accept"))
		{
			ChangeSeed();
			Test();
		}		
	}

	public async void Test()
	{
		ClearMeshes();

		if (WFC == null)
		{
			WFC = new WFC3DModel();
			AddChild(WFC);
		}

		SizeLabel.Text = $"Size: X:{Size.X} Y:{Size.Y} Z:{Size.Z}";
		WFC.Initialize(Size, PrototypeData, Seed.GetHashCode());
		WFC.Stack.Clear();

		ApplyCustomConstraints();
	
		if (Update)
		{
			while (!WFC.IsCollapsed())
			{
				WFC.Iterate();
				ClearMeshes();
				VisualizeWaveFunction();
				ProgressBar.Value = 100*WFC.CollapsedCount()/(Size.X*Size.Y*Size.Z);
				await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);
			}
				
			if (GridMap.GetMeshes().Count == 0)
			{
				ChangeSeed();
				Test();
			}				
			else
				ClearMeshes();
		}
		else
			RegenNoUpdate();

		VisualizeWaveFunction();
	}	

	public void RegenNoUpdate()
	{
		while (!WFC.IsCollapsed())
		{
			WFC.Iterate();
		}
			

		VisualizeWaveFunction();

		if (GridMap.GetMeshes().Count == 0)
		{
			ChangeSeed();
			Test();
		}			
	}


	public void ApplyCustomConstraints()
	{
		for (int z = 0; z < Size.Z; z++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int x = 0; x < Size.X; x++)
				{
					Coords = new Vector3I(x, y, z);
					var Protos = WFC.GetPossibilities(Coords);
					
					if (y == Size.Y - 1)
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var Neighs = PrototypeData[Proto].ValidNeighbours[pZ];
							if (!Neighs.Contains("p-1"))
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}								
						}							
					} 		
					if (y > 0)
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var CustomConstraint = PrototypeData[Proto].ConstrainTo;
							if (CustomConstraint == CONSTRAINT_BOTTOM)
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}
						}							
					}						
					if (y < Size.Y - 1)
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var CustomConstraint = PrototypeData[Proto].ConstrainTo;
							if (CustomConstraint == CONSTRAINT_TOP)
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}
						}
					}
					if (y == 0)
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var Neighs = PrototypeData[Proto].ValidNeighbours[nZ];
							var CustomConstraint = PrototypeData[Proto].ConstrainFrom;
							if (!Neighs.Contains("p-1") || (CustomConstraint == CONSTRAINT_BOTTOM))
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}								
						}							
					}						
					if (x == Size.X - 1)
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var Neighs = PrototypeData[Proto].ValidNeighbours[pX];
							var CustomConstraint = PrototypeData[Proto].ConstrainFrom;
							if (!Neighs.Contains("p-1"))
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}								
						}
					}						
					if (x == 0)
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var Neighs = PrototypeData[Proto].ValidNeighbours[nX];
							var CustomConstraint = PrototypeData[Proto].ConstrainFrom;
							if (!Neighs.Contains("p-1"))
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}								
						}
					}			
					if (z == Size.Z - 1) 
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var Neighs = PrototypeData[Proto].ValidNeighbours[nY];
							var CustomConstraint = PrototypeData[Proto].ConstrainFrom;
							if (!Neighs.Contains("p-1"))
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}								
						}
					}
					if (z == 0)
					{
						foreach (string Proto in new List<string>(Protos))
						{
							var Neighs = PrototypeData[Proto].ValidNeighbours[pY];
							var CustomConstraint = PrototypeData[Proto].ConstrainFrom;
							if (!Neighs.Contains("p-1"))
							{
								Protos.Remove(Proto);
								if (!WFC.Stack.Contains(Coords))
									WFC.Stack.Push(Coords);
							}								
						}
					}						
				}				
			}
		}		
		
		WFC.Propagate(new Vector3I(-1,-1,-1), false);
	}

	public void LoadPrototypeData()
	{
		var JsonAsText = FileAccess.GetFileAsString(JsonPath);
		PrototypeData = JsonConvert.DeserializeObject<Dictionary<string, ItemInfo>>(JsonAsText);
	}

	public void VisualizeWaveFunction(bool OnlyCollapsed = true)
	{
		for (int z = 0; z < Size.Z; z++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int x = 0; x < Size.X; x++)
				{
					var Prototypes = WFC.WaveFunction[x, y, z];

					if (OnlyCollapsed)
						if (Prototypes.Count > 1)
							continue;

					foreach (string Prototype in Prototypes)
					{
						var MeshName = PrototypeData[Prototype].MeshName;
						var MeshRot = PrototypeData[Prototype].MeshRotation;

						if (MeshName == "-1")
							continue;

						int RotIndex = 0;

						switch(MeshRot)
						{
							case 0: 
								RotIndex = 0; 
								break;
							case 1: 
								RotIndex = 16;
								break;
							case 2: 
								RotIndex = 10;
								break;
							case 3: 
								RotIndex = 22;
								break;
						}
						
						var NameInd = int.Parse(string.Join("", MeshName.ToCharArray().Where(Char.IsDigit)));
						GridMap.SetCellItem(new Vector3I(x-Size.X/2,y,z-Size.Z/2), NameInd, RotIndex);
					}						
				}				
			}
		}							
	}
		
	public void ClearMeshes()
	{
		GridMap.Clear();
	}

	public void ChangeSeed()
	{
		Seed++;
		SeedLabel.Text = "Seed: " + Seed;
	}
}