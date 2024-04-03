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
	string JsonPath = "res://generation_3d/meshes/meshes_faster_gen/prototype_data.json";
	[Export]
	Vector3I Size = new(8, 3, 8);

	[Export]
	int Seed = 0;
	[Export] 
	bool Update = false;
	[Export] 
	bool UsePrebuild = false;

	private GridMap gridMap;
	private Label seedLabel;
	private Label sizeLabel;
	private ProgressBar progressBar;

	Dictionary<string, ItemInfo> PrototypeData;
	WFC3DModel WFC = null;
	Vector3I Coords;

	private Dictionary<Vector3I, Tuple<int, int>> gridMapState = new();

	public override void _Ready()
	{
		gridMap = GetNode<GridMap>("GridMap");
		seedLabel = GetNode<Label>("Labels/SeedLabel");
		sizeLabel = GetNode<Label>("Labels/SizeLabel");
		progressBar = GetNode<ProgressBar>("ProgressBar");
		seedLabel.Text = "Seed: " + Seed;

		SaveGridMapState();
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
		gridMap.Clear();

		if (UsePrebuild)
		{
			LoadGridMapState();
		}

		if (WFC == null)
		{
			WFC = new WFC3DModel();
			AddChild(WFC);
		}

		sizeLabel.Text = $"Size: X:{Size.X} Y:{Size.Y} Z:{Size.Z}";
		WFC.Initialize(Size, PrototypeData, Seed.GetHashCode());
		WFC.Stack.Clear();

		ApplyCustomConstraints();

		if (UsePrebuild)
		{			
			BuildOnExisting();
		}

		if (Update)
		{
			while (!WFC.IsCollapsed())
			{
				WFC.Iterate();
				gridMap.Clear();
				VisualizeWaveFunction();
				progressBar.Value = 100*WFC.CollapsedCount()/(Size.X*Size.Y*Size.Z);
				await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);
			}
				
			if (gridMap.GetMeshes().Count == 0)
			{
				ChangeSeed();
				Test();
			}				
			else
				gridMap.Clear();
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
			
		gridMap.Clear();
		VisualizeWaveFunction();

		if (gridMap.GetMeshes().Count == 0)
		{
			ChangeSeed();
			Test();
		}			
	}


	public void ApplyCustomConstraints()
	{
		for (int x = 0; x < Size.X; x++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int z = 0; z < Size.Z; z++)
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

	
	public void SaveGridMapState()
	{
		var UsedCells = gridMap.GetUsedCells();

		foreach (Vector3I Cell in UsedCells)
		{
			gridMapState[Cell] = new Tuple<int, int>(gridMap.GetCellItem(Cell), gridMap.GetCellItemOrientation(Cell));
		}
	}

	public void LoadGridMapState()
	{
		foreach (Vector3I Cell in gridMapState.Keys)
		{
			gridMap.SetCellItem(Cell, gridMapState[Cell].Item1, gridMapState[Cell].Item2);
		}
	}

	public void BuildOnExisting()
	{
		for (int x = 0; x < Size.X; x++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int z = 0; z < Size.Z; z++)
				{
					Coords = new Vector3I(x,y,z);

					var Item = gridMap.GetCellItem(new Vector3I(x-Size.X/2,y,z-Size.Z/2));
					
					if (Item==-1)
						continue;

					var RotIndex = gridMap.GetCellItemOrientation(new Vector3I(x-Size.X/2,y,z-Size.Z/2));
					var MeshRot = -1;

					switch(RotIndex)
					{
						case 0: 
							MeshRot = 0; 
							break;
						case 16: 
							MeshRot = 1;
							break;
						case 10: 
							MeshRot = 2;
							break;
						case 22: 
							MeshRot = 3;
							break;
					}

					foreach (string Prototype in PrototypeData.Keys)
					{
						var Name = PrototypeData[Prototype].MeshName;
						var Rotation = PrototypeData[Prototype].MeshRotation;

						var NameInd = int.Parse(string.Join("", Name.ToCharArray().Where(Char.IsDigit)));
						if (NameInd == Item && Rotation == MeshRot)
						{
							WFC.WaveFunction[x,y,z] = new List<string>() { Prototype };
							if (!WFC.Stack.Contains(Coords))
								WFC.Stack.Push(Coords);
							break;
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
		for (int x = 0; x < Size.X; x++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int z = 0; z < Size.Z; z++)
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
						gridMap.SetCellItem(new Vector3I(x-Size.X/2,y,z-Size.Z/2), NameInd, RotIndex);
					}						
				}				
			}
		}							
	}
		
	public void ChangeSeed()
	{
		Seed++;
		seedLabel.Text = "Seed: " + Seed;
	}
}