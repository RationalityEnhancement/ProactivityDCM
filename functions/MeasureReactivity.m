function reactivity=MeasureReactivity(p_A_without_stimulus,p_A_with_stimulus,actions)

reactivity = kldiv(actions,p_A_with_stimulus,p_A_without_stimulus);

end