function cost = mse(outputs,labels)
   cost = mean(sum((outputs - labels).^2));
end