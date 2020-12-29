function GD=MeasureGoalDirectedness(p_AS_with_goal,p_AS_without_goal,SA_pairs)

GD = kldiv(SA_pairs,p_AS_with_goal,p_AS_without_goal);

end